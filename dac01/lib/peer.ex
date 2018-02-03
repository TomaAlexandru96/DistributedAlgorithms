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

    run_broadcast(peer_id, false, false, send_state, receive_state, receiveP)
  end

  defp run_broadcast(peer_id, send_stopped, receive_stopped, send_state, receive_state, receiveP) do
    if send_stopped and receive_stopped do
      end_broadcast(peer_id, Enum.zip(send_state, receive_state))
    end

    {new_send_stopped, new_receive_stopped, new_send_state, new_receive_state} = receive do
      {:stop_send, state} ->
        {true, receive_stopped, state, receive_state}
      {:stop_receive, state} ->
        {send_stopped, true, send_state, state}
      {:send, content} ->
        # redirect to receive process
        send receiveP, {:send, content}
        {send_stopped, receive_stopped, send_state, receive_state}
    end

    run_broadcast(peer_id, new_send_stopped, new_receive_stopped, new_send_state, new_receive_state, receiveP)
  end

  # prints the state of the peer
  defp end_broadcast(peer_id, state) do
    IO.puts "#{peer_id}: #{inspect(state)}"
  end

end
