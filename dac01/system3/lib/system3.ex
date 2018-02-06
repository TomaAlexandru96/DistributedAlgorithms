# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule System3 do

  def main() do
    { peers, _ } = Integer.parse(Enum.at(System.argv() , 0));
    { max_broadcasts, _ } = Integer.parse(Enum.at(System.argv() , 1));
    { timeout, _ } = Integer.parse(Enum.at(System.argv() , 2));
    start(true, peers, max_broadcasts, timeout)
  end

  def main_net() do
    { peers, _ } = Integer.parse(Enum.at(System.argv() , 0));
    { max_broadcasts, _ } = Integer.parse(Enum.at(System.argv() , 1));
    { timeout, _ } = Integer.parse(Enum.at(System.argv() , 2));
    IO.puts "#{inspect peers}, #{inspect max_broadcasts}, #{inspect timeout}"
    start(false, peers, max_broadcasts, timeout)
  end

  defp start(is_local, nr_of_peers, max_broadcasts, timeout) do
    IO.puts "Starting #{if is_local do "local" else "on docker" end} with nr_of_peers: #{nr_of_peers}, max_broadcasts: #{max_broadcasts}, timeout: #{timeout}"
    IO.puts ""

    for i <- 1..nr_of_peers do
      peer = if is_local do
        spawn(Peer, :start, [i-1, self(), nr_of_peers])
      else
        Node.spawn(:'node#{i}@container#{i}.localdomain', Peer, :start, [i-1, self(), nr_of_peers])
      end
    end

    peers_pl = for _ <- 1..nr_of_peers do
      receive do
        {:pl_bind, peer_id, pl} -> {peer_id, pl}
      end
    end

    # send neighbours of pl
    for {peer_id, pl} <- peers_pl do
      send pl, {:bind, peers_pl}
    end

    for {peer_id, pl} <- peers_pl do
      send pl, {:broadcast_app, max_broadcasts, timeout}
    end
  end

end
