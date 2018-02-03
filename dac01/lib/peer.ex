# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule Peer do

  # send state [0, 0, 0, 0, 0]
  def send_peer(peer_id, neighbours, max_broadcasts, timeout, send_state, parent_process) do
    should_stop = not Enum.reduce(for i <- 0..length(neighbours)-1 do
      Enum.at(send_state, i) < max_broadcasts
    end, fn(x, y) -> x or y end)

    # stop broadcst
    if should_stop do
      send parent_process, {:stop_send, send_state}
    else
      new_state = for i <- 0..length(neighbours)-1 do
        should_send = Enum.at(send_state, i) < max_broadcasts
        if should_send do
          send Enum.at(neighbours, i), {:send, peer_id}
          Enum.at(send_state, i) + 1
        else
          Enum.at(send_state, i)
        end
      end

      send_peer(peer_id, neighbours, max_broadcasts, timeout, new_state, parent_process)
    end
  end

  # receive state [0, 0, 0, 0, 0]
  def receive_peer(peer_id, neighbours, max_broadcasts, timeout, receive_state, parent_process) do
    should_stop = not Enum.reduce(for i <- 0..length(neighbours)-1 do
      Enum.at(receive_state, i) < max_broadcasts
    end, fn(x, y) -> x or y end)

    if should_stop do
      send parent_process, {:stop_receive, receive_state}
    else
      new_state = receive do
        {:send, from} ->
          List.replace_at(receive_state, from, Enum.at(receive_state, from) + 1)
      end

      IO.puts inspect receive_state

      receive_peer(peer_id, neighbours, max_broadcasts, timeout, new_state, parent_process)
    end
  end

  def start(peer_id) do
    receive do
      {:bind, neighbours} -> next(peer_id, neighbours)
    end
  end

  defp next(peer_id, neighbours) do
    receive do
      {:broadcast, max_broadcasts, timeout} ->
        start_broadcast(peer_id, neighbours, max_broadcasts, timeout)
    end
  end

  defp start_broadcast(peer_id, neighbours, max_broadcasts, timeout) do
    send_state = for _ <- 0..length(neighbours)-1, do: 0
    receive_state = for _ <- 0..length(neighbours)-1, do: 0
    sendP = spawn(Peer, :send_peer, [peer_id, neighbours, max_broadcasts, timeout, send_state, self()])
    receiveP = spawn(Peer, :receive_peer, [peer_id, neighbours, max_broadcasts, timeout, receive_state, self()])

    run_broadcast(peer_id, false, false, send_state, receive_state)
  end

  defp run_broadcast(peer_id, send_stopped, receive_stopped, send_state, receive_state) do
    if send_stopped and receive_stopped do
      end_broadcast(peer_id, Enum.zip(send_state, receive_state))
    end

    {new_send_stopped, new_receive_stopped, new_send_state, new_receive_state} = receive do
      {:stop_send, state} ->
        {true, receive_stopped, state, receive_state}
      {:stop_receive, state} ->
        {send_stopped, true, send_state, state}
    end

    run_broadcast(peer_id, new_send_stopped, new_receive_stopped, new_send_state, new_receive_state)
  end

  # defp start_broadcast(peer_id, neighbours, max_broadcasts, timeout, state) do
  #   # check if there are any receive or send left
  #   res = for i <- 0..length(neighbours)-1 do
  #     {first, second} = Enum.at(state, i)
  #     if first < max_broadcasts || second < max_broadcasts do
  #       True
  #     else
  #       False
  #     end
  #   end
  #
  #   # if threre are no more sends or receive to be made then print the state
  #   if !Enum.reduce(res, fn(b1, b2) -> b1 || b2 end) do
  #     end_broadcast(peer_id, state)
  #   else
  #     for i <- 0..length(neighbours)-1 do
  #       {first, second} = Enum.at(state, i)
  #
  #       if first < max_broadcasts do
  #         state = List.replace_at(state, peer_id, {first + 1, second})
  #         send Enum.at(neighbours, i), {:send, peer_id, state}
  #         end_broadcast(peer_id, state)
  #       end
  #     end
  #
  #     receive do
  #      {:send, from, prevState} ->
  #        {first, second} = Enum.at(prevState, from)
  #
  #        if second < max_broadcasts do
  #          state = List.replace_at(state, from, {first, second + 1})
  #          end_broadcast(peer_id, state)
  #        end
  #     end
  #
  #     start_broadcast(peer_id, neighbours, max_broadcasts, timeout, state)
  #   end
  # end

  # prints the state of the peer
  defp end_broadcast(peer_id, state) do
    IO.puts "#{peer_id}: #{inspect(state)}"
  end

end
