# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule Peer do

  def start(peer_id) do
    receive do 
      {:bind, neighbours} -> next(peer_id, neighbours)
    end
  end

  def next(peer_id, neighbours) do
    receive do
      {:broadcast, max_broadcasts, timeout} -> 
        data = for _ <- neighbours, do: {0, 0}
        start_broadcast(peer_id, neighbours, max_broadcasts, timeout, data)
    end
  end

  def start_broadcast(peer_id, neighbours, max_broadcasts, timeout, data) do
    IO.puts "#{inspect(data)}"

    data = receive do
      {:send} ->
        {first, second} = Enum.at(data, peer_id)
        if second < max_broadcasts do
        end
    end
        
    {first, second} = Enum.at(data, peer_id)
    if first < max_broadcasts do
      for n <- neighbours do
        send n, {:send}
      end
    end
    
    start_broadcast(peer_id, neighbours, max_broadcasts, timeout, data)
  end

  def replace_data_with(data, index, tuple) do
    :lists.sublist(data, index) ++ tuple ++ :lists.sublist(data, index + 2, length(data))
  end

end
