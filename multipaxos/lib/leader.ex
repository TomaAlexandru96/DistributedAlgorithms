defmodule Leader do
  def start(config) do
    receive do
      {:bind, acceptors, replicas} ->
        acceptors = MapSet.new(acceptors)
        replicas = MapSet.new(replicas)
        ballot_num = {0, self()}
        spawn(Scout, :start, [self(), acceptors, ballot_num])
        next(config, acceptors, replicas, ballot_num, false, Map.new)
    end
  end

  def next(config, acceptors, replicas, ballot_num, active, proposals) do
    receive do
      {:propose, slot, command} ->
        next(config, acceptors, replicas, ballot_num, active, proposals)
      {:adopted, ballot, pvalues} ->
        next(config, acceptors, replicas, ballot_num, active, proposals)
      {:preempted, {seq, leader}=ballot} ->
        if ballot > ballot_num do
          active = false
          ballot_num = {seq + 1, self()}
          spawn(Scout, :start, [self(), acceptors, ballot_num])
          next(config, acceptors, replicas, ballot_num, active, proposals)
        else
          next(config, acceptors, replicas, ballot_num, active, proposals)
        end
    end
  end
end
