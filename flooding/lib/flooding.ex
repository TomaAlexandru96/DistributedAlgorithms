defmodule Flooding do

  def main do
    peer_nr = 10

    peers = for _ <- 0..peer_nr, do: spawn(Peer, :start, [])

    # for peer <- peers do
    #  send peer, {:bind, peers}
    # end

    send_peers(0, [1, 6], peers) # peer 0's neighbours are peers 1 and 6
    send_peers(1, [0, 2, 3], peers)
    send_peers(2, [1, 3, 4], peers)
    send_peers(3, [1, 2, 5], peers)
    send_peers(4, [2], peers)
    send_peers(5, [3], peers)
    send_peers(6, [0, 7], peers)
    send_peers(7, [6, 8, 9], peers)
    send_peers(8, [7, 9], peers)
    send_peers(9, [7, 8], peers) # peer 9's neighbours are peers 7 and 8

    [p | ps] = peers
    send p, {:hello, "From Flooding", p}
  end

  def send_peers(index, peers, all) do
    send Enum.at(all, index), {:bind, Enum.map(peers, fn(x) -> Enum.at(all, x) end)}
  end

end
