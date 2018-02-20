defmodule Acceptor do
  @bottom -1

  def start(config) do
    next(config, @bottom, MapSet.new)
  end

  def next(config, ballot_num, accepted) do
    receive do
      # Phase 1a of the Synod protocol
      {:p1a, leader, ballot} ->
        ballot_num = if ballot > ballot_num do
          ballot
        else
          ballot_num
        end
        send leader, {:p1b, self(), ballot_num, accepted}
        next(config, ballot_num, accepted)

      # Phase 2a of the Synod protocol
      {:p2a, leader, {ballot, _slot, _command} = pvalue} ->
        accepted = if ballot == ballot_num do
          MapSet.put(accepted, pvalue)
        else
          accepted
        end
        send leader, {:p2b, self(), ballot_num}
        next(config, ballot_num, accepted)

      {:ping, leader, timestamp} ->
        # The ping mechanism is used to measure the mean RTT from
        # a leader to all acceptors.
        send leader, {:pong, timestamp}
        next(config, ballot_num, accepted)
    end
  end
end
