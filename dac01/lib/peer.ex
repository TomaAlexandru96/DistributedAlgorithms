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
          state = List.replace_at(state, peer_id, {first + 1, second})
          send Enum.at(neighbours, i), {:send, peer_id, state}
          end_broadcast(peer_id, state)
        end
      end

      receive do
       {:send, from, prevState} ->
         {first, second} = Enum.at(prevState, from)

         if second < max_broadcasts do
           state = List.replace_at(state, from, {first, second + 1})
           end_broadcast(peer_id, state)
         end
      end

      start_broadcast(peer_id, neighbours, max_broadcasts, timeout, state)
    end
  end

  # prints the state of the peer
  defp end_broadcast(peer_id, state) do
    IO.puts "#{peer_id}: #{inspect(state)}"
  end

end
