# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule System6 do

  def main() do
    { peers, _ } = Integer.parse(Enum.at(System.argv() , 0));
    { max_broadcasts, _ } = Integer.parse(Enum.at(System.argv() , 1));
    { timeout, _ } = Integer.parse(Enum.at(System.argv() , 2));
    { send_percentage, _} = Integer.parse(Enum.at(System.argv(), 3))
    start(true, peers, max_broadcasts, timeout, send_percentage)
  end

  def main_net() do
    { peers, _ } = Integer.parse(Enum.at(System.argv() , 0));
    { max_broadcasts, _ } = Integer.parse(Enum.at(System.argv() , 1));
    { timeout, _ } = Integer.parse(Enum.at(System.argv() , 2));
    { send_percentage, _} = Integer.parse(Enum.at(System.argv(), 3))
    start(false, peers, max_broadcasts, timeout, send_percentage)
  end

  defp start(is_local, nr_of_peers, max_broadcasts, timeout, send_percentage) do
    IO.puts "Starting #{if is_local do "local" else "on docker" end} with nr_of_peers: #{nr_of_peers}, max_broadcasts: #{max_broadcasts}, timeout: #{timeout}"
    IO.puts ""

    for i <- 1..nr_of_peers do
      peer = if is_local do
        spawn(Peer, :start, [i-1, self(), nr_of_peers, send_percentage])
      else
        Node.spawn(:'node#{i}@container#{i}.localdomain', Peer, :start, [i-1, self(), nr_of_peers, send_percentage])
      end
    end

    peers_lpl = for _ <- 1..nr_of_peers do
      receive do
        {:lpl_bind, peer_id, lpl} -> {peer_id, lpl}
      end
    end

    # send neighbours of lpl
    for {peer_id, lpl} <- peers_lpl do
      send lpl, {:bind, peers_lpl}
    end

    # start broadcast
    for {peer_id, lpl} <- peers_lpl do
      send lpl, {:broadcast_app, max_broadcasts, timeout}
    end
  end

end
