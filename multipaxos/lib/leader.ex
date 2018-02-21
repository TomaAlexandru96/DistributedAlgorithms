# Alexandru Toma (ait15) and Alexandru Dan (ad5915)

defmodule Leader do
  @bottom -1
  @measure_interval 1000
  @max_preempts 3

  def start(config, monitor) do
    receive do
      {:bind, acceptors, replicas} ->
        acceptors = MapSet.new(acceptors)
        replicas = MapSet.new(replicas)
        ballot_num = {0, self()}
        spawn(Scout, :start, [self(), config, monitor, acceptors, ballot_num])

        :timer.send_after(@measure_interval, self(), :measure_rtt)
        next(config, monitor, acceptors, replicas, ballot_num, false, %{}, 0, 0)
    end
  end

  def next(config, monitor, acceptors, replicas, ballot_num, active, proposals, rtt, preempts) do
    receive do
      # A mechanism to measure RTTs to establish random delays when sending
      # packets. The RTTs are a useful measure to be able to tell on what
      # range of times should the delays lie.
      :measure_rtt ->
        Enum.map(acceptors, fn(acceptor) ->
          send acceptor, {:ping, self(), :os.system_time(:milli_seconds)}
        end)

        # This does not take into account failures, but it should be easily
        # adapted by adding timeouts.
        rtt_sum = Enum.reduce(acceptors, 0, fn(_acceptor, rtt_sum) ->
          rtt_sum = receive do
            {:pong, timestamp} ->
              timestamp2 = :os.system_time(:milli_seconds)
              rtt_sum + timestamp2 - timestamp
          end
          rtt_sum
        end)

        rtt = rtt_sum / MapSet.size(acceptors)

        # Ping messages are sent at a regular interval @measure_interval ms
        :timer.send_after(@measure_interval, self(), :measure_rtt)

        next(config, monitor, acceptors, replicas, ballot_num, active, proposals, rtt, preempts)

      # A proposal is put into a slot only if the respective slot is empty.
      # Commanders get spawed if the leader is in active mode.
      {:propose, slot, command} ->
        if proposals[slot] == nil do
          if active do
            spawn(Commander, :start,
              [self(), config, monitor, acceptors, replicas, {ballot_num, slot, command}])
          end
          next(config, monitor, acceptors, replicas, ballot_num, active, Map.put(proposals, slot, command), rtt, preempts)
        end
        next(config, monitor, acceptors, replicas, ballot_num, active, proposals, rtt, preempts)

      {:adopted, _ballot, pvalues} ->
        # Get maxim ballot number to compute pmax(pvalues)
        bmax = Enum.reduce(pvalues, @bottom, fn(pvalue, bmax) ->
            {ballot, _, _} = pvalue
            if ballot > bmax do
              ballot
            else
              bmax
            end
          end)

        # Compute pmax(pvalues)
        pmax = Map.new(Enum.map(
          Enum.filter(pvalues, fn({ballot, _, _}) ->
            ballot == bmax
          end), fn({_, slot, command}) ->
            {slot, command}
        end))

        # proposals = proposals <| pmax(pvalues)
        proposals = Enum.reduce(proposals, pmax, fn({slot, command}, pmax) ->
          pmax = if pmax[slot] == nil do
            Map.put(pmax, slot, command)
          else
            pmax
          end
          pmax
        end)

        # Go into active mode since we received a quorum of responses.
        active = true

        # Spawn commanders for all proposals since we are in active mode.
        Enum.map(proposals, fn({slot, command}) ->
          spawn(Commander, :start,
            [self(), config, monitor, acceptors, replicas, {ballot_num, slot, command}])
        end)

        next(config, monitor, acceptors, replicas, ballot_num, active, proposals, rtt, 0)

      {:preempted, {seq, _leader} = ballot} ->
        if ballot > ballot_num do
          active = false
          ballot_num = {seq + 1, self()}
          spawn(Scout, :start, [self(), config, monitor, acceptors, ballot_num])
          next(config, monitor, acceptors, replicas, ballot_num, active, proposals, rtt, 0)
        else
          # If we preempted @max_preempts times without chaging the ballot number,
          # we may be in a lack of progress situation. In such a case we choose to
          # itroduce random delays in the leaders to achieve different orderings.
          if preempts >= @max_preempts do
            :timer.sleep(Kernel.round(2 * :rand.uniform() * rtt))
            next(config, monitor, acceptors, replicas, ballot_num, active, proposals, rtt, 0)
          else
            next(config, monitor, acceptors, replicas, ballot_num, active, proposals, rtt, preempts + 1)
          end
        end
    end
  end
end
