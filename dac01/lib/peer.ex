# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule Peer do

  def start(peer_id) do
    receive do
      {:bind, neighbours} -> next(peer_id, neighbours)
    end
  end

  defp next(peer_id, neighbours) do
    receive do
      {:broadcast, max_broadcasts, timeout} ->
        data = for _ <- neighbours, do: {0, 0}
        start_broadcast(peer_id, neighbours, max_broadcasts, timeout, data)
    end
  end

  defp start_broadcast(peer_id, neighbours, max_broadcasts, timeout, data) do
    {first, second} = Enum.at(data, peer_id)

    if first < max_broadcasts do
      for n <- neighbours do
        send n, {:send, peer_id}
        replace_data_with(data, n + 1, {first + 1, second})
      end
    end

    receive do
      {:send, from} ->
        {first, second} = Enum.at(data, peer_id)
        if second < max_broadcasts do
          # replace_data_with(data, from + 1, {first, second + 1})
        end
    end

    # start_broadcast(peer_id, neighbours, max_broadcasts, timeout, data)
    display_data(peer_id, data)
  end

  # function that replaces an item in a list at index (1-indexed)
  def replace_data_with(data, index, tuple) do
    :lists.sublist(data, index-1) ++ [tuple] ++
          :lists.sublist(data, index+1, length(data))
  end

  def display_data(peer_id, data) do
    IO.puts "#{peer_id}: #{inspect(data)}"
  end

end
