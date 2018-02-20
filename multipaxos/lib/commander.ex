defmodule Commander do
  def start(leader, config, monitor, acceptors, replicas, pvalue) do
    send monitor, {:commander, config[:server_num]}

    Enum.map(acceptors, fn(acc) ->
        send acc, {:p2a, self(), pvalue}
      end)
    next(leader, acceptors, replicas, pvalue, acceptors)
  end

  def next(leader, acceptors, replicas, pvalue, waitfor) do
    {ballot_num, slot, command} = pvalue
    receive do
      {:p2b, acceptor, ballot} ->
        if ballot == ballot_num do
          waitfor = MapSet.delete(waitfor, acceptor)
          if MapSet.size(waitfor) < MapSet.size(acceptors) / 2 do
            Enum.map(replicas, fn(rep) ->
                send rep, {:decision, slot, command}
              end)
          else
            next(leader, acceptors, replicas, pvalue, waitfor)
          end
        else
          send leader, {:preempted, ballot}
        end
    end
  end
end
