defmodule Acceptor do
  @bottom {-1, self()}

  def start(config) do
    next(config, @bottom, MapSet.new)
  end

  def next(config, ballot_num, accepted) do
    # IO.puts inspect ballot_num
    receive do
      {:p1a, leader, ballot} ->
        ballot_num = if ballot > ballot_num do
          ballot
        else
          ballot_num
        end
        send leader, {:p1b, self(), ballot_num, accepted}
        next(config, ballot_num, accepted)
      {:p2a, leader, {ballot, slot, command}=pvalue} ->
        accepted = if ballot == ballot_num do
          MapSet.put(accepted, pvalue)
        else
          accepted
        end
        send leader, {:p2b, self(), ballot_num}
        next(config, ballot_num, accepted)

      {:ping, leader, timestamp} ->
        send leader, {:pong, timestamp}
        next(config, ballot_num, accepted)
    end
  end
end
