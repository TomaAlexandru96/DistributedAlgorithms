# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule System1 do

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

    peers = for i <- 1..nr_of_peers do
      if is_local do
        spawn(Peer, :start, [i-1])
      else
        Node.spawn(:'node#{i}@container#{i}.localdomain', Peer, :start, [i-1])
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
