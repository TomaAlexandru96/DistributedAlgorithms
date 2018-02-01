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
        state = for _ <- neighbours, do: {0, 0}
        start_broadcast(peer_id, neighbours, max_broadcasts, timeout, state)
    end
  end

  defp start_broadcast(peer_id, neighbours, max_broadcasts, timeout, state) do
    # check if there are any receive or send left
    res = for i <- 0..length(neighbours)-1 do
      {first, second} = Enum.at(state, i)
      if first < max_broadcasts || second < max_broadcasts do
        True
      else
        False
      end
    end

    # if threre are no more sends or receive to be made then print the state
    if !Enum.reduce(res, fn(b1, b2) -> b1 || b2 end) do
      end_broadcast(peer_id, state)
    else
      for i <- 0..length(neighbours)-1 do
        {first, second} = Enum.at(state, i)

        if first < max_broadcasts do
          send Enum.at(neighbours, i), {:send, peer_id}
          end_broadcast(peer_id, state)
          replace_list(state, i + 1, {first + 1, second})
        end
      end

      receive do
       {:send, from} ->
         {first, second} = Enum.at(state, from)

         if second < max_broadcasts do
           end_broadcast(peer_id, state)
           replace_list(state, from + 1, {first, second + 1})
         end
      end

      start_broadcast(peer_id, neighbours, max_broadcasts, timeout, state)
    end
  end

  # prints the state of the peer
  defp end_broadcast(peer_id, state) do
    IO.puts "#{peer_id}: #{inspect(state)}"
  end

  # function that replaces an item in a list at index (1-indexed)
  def replace_list(list, index, element) do
    :lists.sublist(list, index-1) ++ [element] ++
          :lists.sublist(list, index+1, length(list))
  end

end
