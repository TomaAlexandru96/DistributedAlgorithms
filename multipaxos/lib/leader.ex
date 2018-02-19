defmodule Leader do
  @bottom {-1, self()}

  def start(config) do
    receive do
      {:bind, acceptors, replicas} ->
        acceptors = MapSet.new(acceptors)
        replicas = MapSet.new(replicas)
        ballot_num = {0, self()}
        spawn(Scout, :start, [self(), acceptors, ballot_num])
        next(config, acceptors, replicas, ballot_num, false, %{})
    end
  end

  def next(config, acceptors, replicas, ballot_num, active, proposals) do
    receive do
      {:propose, slot, command} ->
        if proposals[slot] == nil do
          if active do
            spawn(Commander, :start,
              [self(), acceptors, replicas, {ballot_num, slot, command}])
          end
          next(config, acceptors, replicas, ballot_num, active, Map.put(proposals, slot, command))
        end
        next(config, acceptors, replicas, ballot_num, active, proposals)
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

        next(config, acceptors, replicas, ballot_num, active, proposals)
      {:preempted, {seq, leader}=ballot} ->
        if ballot > ballot_num do
          active = false
          ballot_num = {seq + 1, leader}
          spawn(Scout, :start, [leader, acceptors, ballot_num])
          next(config, acceptors, replicas, ballot_num, active, proposals)
        else
          next(config, acceptors, replicas, ballot_num, active, proposals)
        end
    end
  end
end
