defmodule Leader do
  @bottom {-1, self()}
  @measure_interval 1000
  @max_preempts 3

  def start(config) do
    receive do
      {:bind, acceptors, replicas} ->
        acceptors = MapSet.new(acceptors)
        replicas = MapSet.new(replicas)
        ballot_num = {0, self()}
        spawn(Scout, :start, [self(), acceptors, ballot_num])

        :timer.send_after(@measure_interval, self(), :measure_rtt)
        next(config, acceptors, replicas, ballot_num, false, %{}, 0, 0)
    end
  end

  def next(config, acceptors, replicas, ballot_num, active, proposals, rtt, preempts) do
    receive do
      :measure_rtt ->
        Enum.map(acceptors, fn(acceptor) ->
          send acceptor, {:ping, self(), :os.system_time(:milli_seconds)}
        end)

        rtt_sum = Enum.reduce(acceptors, 0, fn(acceptor, rtt_sum) ->
          rtt_sum = receive do
            {:pong, timestamp} ->
              timestamp2 = :os.system_time(:milli_seconds)
              rtt_sum + timestamp2 - timestamp
          end
          rtt_sum
        end)

        rtt = rtt_sum / MapSet.size(acceptors)
        :timer.send_after(@measure_interval, self(), :measure_rtt)

        next(config, acceptors, replicas, ballot_num, active, proposals, rtt, preempts)

      {:propose, slot, command} ->
        if proposals[slot] == nil do
          if active do
            spawn(Commander, :start,
              [self(), acceptors, replicas, {ballot_num, slot, command}])
          end
          next(config, acceptors, replicas, ballot_num, active, Map.put(proposals, slot, command), rtt, preempts)
        end
        next(config, acceptors, replicas, ballot_num, active, proposals, rtt, preempts)
      {:adopted, ballot, pvalues} ->
        # get maxim ballot number to compute pmax(pvalues)
        bmax = Enum.reduce(pvalues, @bottom, fn(pvalue, bmax) ->
            {ballot, _, _} = pvalue
            if ballot > bmax do
              ballot
            else
              bmax
            end
          end)

        # compute pmax(pvalues)
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

        # Spawn commanders for all proposals
        Enum.map(proposals, fn({slot, command}) ->
          spawn(Commander, :start,
            [self(), acceptors, replicas, {ballot_num, slot, command}])
        end)

        active = true

        next(config, acceptors, replicas, ballot_num, active, proposals, rtt, 0)
      {:preempted, {seq, leader}=ballot} ->
        if ballot > ballot_num do
          active = false
          ballot_num = {seq + 1, self()}
          spawn(Scout, :start, [self(), acceptors, ballot_num])
          next(config, acceptors, replicas, ballot_num, active, proposals, rtt, 0)
        else
          if preempts >= @max_preempts do
            :timer.sleep(Kernel.round(rtt + :rand.uniform() * rtt))
            next(config, acceptors, replicas, ballot_num, active, proposals, rtt, 0)
          else
            next(config, acceptors, replicas, ballot_num, active, proposals, rtt, preempts + 1)
          end
        end
    end
  end
end
