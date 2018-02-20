defmodule Scout do
  def start(leader, config, monitor, acceptors, ballot_num) do
    # When the scout is created it starts the phase 1 of the Synod
    # protocol and wait for responses from the acceptors.
    send monitor, {:scout, config[:server_num]}

    Enum.map(acceptors, fn(acc) ->
      send acc, {:p1a, self(), ballot_num}
    end)
    next(leader, acceptors, ballot_num, acceptors, MapSet.new)
  end

  def next(leader, acceptors, ballot_num, waitfor, pvalues) do
    receive do
      {:p1b, acceptor, ballot, acc_pvalues} ->
        # From the invariants, ballot >= ballot_num
        if ballot == ballot_num do
          pvalues = MapSet.union(pvalues, acc_pvalues)
          waitfor = MapSet.delete(waitfor, acceptor)

          # Wait for quorum to adopt a proposal.
          if MapSet.size(waitfor) < MapSet.size(acceptors) / 2 do
            send leader, {:adopted, ballot, pvalues}
          else
            next(leader, acceptors, ballot_num, waitfor, pvalues)
          end
        else
          # The scout is stopped and leader is preempted
          # when a bigger ballot number is received, begining a new round.
          send leader, {:preempted, ballot}
        end
    end
  end
end
