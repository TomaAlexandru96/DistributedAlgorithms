defmodule Scout do
  def start(leader, acceptors, ballot_num) do
    Enum.map(acceptors, fn(acc) ->
        send acc, {:p1a, self(), ballot_num}
      end)
    next(leader, acceptors, ballot_num, acceptors, MapSet.new)
  end

  def next(leader, acceptros, ballot_num, waitfor, pvalues) do
    receive do
      {:p1b, acceptor, ballot, acc_pvalues} ->
        if ballot == ballot_num do
          pvalues = MapSet.union(pvalues, acc_pvalues)
          waitfor = MapSet.delete(waitfor, acceptor)
          if MapSet.size(waitfor) < MapSet.size(acceptor) / 2 do
            send leader, {:adopted, ballot, pvalues}
          else
            next(leader, acceptros, ballot_num, waitfor, pvalues)
          end
        else
          send leader, {:preempted, ballot}
        end
    end
  end
end
