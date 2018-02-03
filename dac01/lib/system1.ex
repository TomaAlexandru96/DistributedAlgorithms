# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule System1 do

  def start(is_local, nr_of_peers, max_broadcasts, timeout) do
    peers = for i <- 0..nr_of_peers-1 do
      if is_local do
        spawn(PeerSystem1, :start, [i])
      else
        IO.puts "TODO"
        nil
      end
    end

    for p <- peers do
      send p, {:bind, peers}
    end

    for p <- peers do
      send p, {:broadcast, max_broadcasts, timeout}
    end
  end

end
