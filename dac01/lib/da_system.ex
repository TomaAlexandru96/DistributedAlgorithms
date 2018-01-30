# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule DASystem do

  def start(nr_of_peers, max_broadcasts, timeout) do
    peers = for i <- 0..nr_of_peers-1, do: spawn(Peer, :start, [i])

    for p <- peers do
      send p, {:bind, peers}
    end

    for p <- peers do
      send p, {:broadcast, max_broadcasts, timeout}
    end
  end

end
