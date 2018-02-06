# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule App do

  def has_exceeded_timeout(timeout, start_time) do
    now = :os.system_time(:milli_seconds)
    (now - start_time) > timeout
  end

  # send state [0, 0, 0, 0, 0]
  def send_peer(peer_id, neighbours, max_broadcasts, timeout, send_state, parent_process, start_time) do
    should_stop = not Enum.reduce(for i <- 0..neighbours-1 do
      Enum.at(send_state, i) < max_broadcasts
    end, fn(x, y) -> x or y end)

    should_stop = should_stop or has_exceeded_timeout(timeout, start_time)

    # stop broadcst
    if should_stop do
      send parent_process, {:stop_send, send_state}
    else
      new_state = for i <- 0..neighbours-1 do
        Enum.at(send_state, i) + 1
      end

      send parent_process, {:erb_broadcast, {:send, peer_id}}
      send_peer(peer_id, neighbours, max_broadcasts, timeout, new_state, parent_process, start_time)
    end
  end

  # receive state [0, 0, 0, 0, 0]
  def receive_peer(peer_id, neighbours, max_broadcasts, timeout, receive_state, parent_process, start_time) do
    should_stop = not Enum.reduce(for i <- 0..neighbours-1 do
      Enum.at(receive_state, i) < max_broadcasts
    end, fn(x, y) -> x or y end)

    should_stop = should_stop or has_exceeded_timeout(timeout, start_time)

    if should_stop do
      send parent_process, {:stop_receive, receive_state}
    else
      remaining_time = timeout - (:os.system_time(:milli_seconds) - start_time)

      new_state = receive do
        {:send, from} ->
          List.replace_at(receive_state, from, Enum.at(receive_state, from) + 1)
        after
          remaining_time -> receive_state
      end

      receive_peer(peer_id, neighbours, max_broadcasts, timeout, new_state, parent_process, start_time)
    end
  end

  def start(peer_id, erb, neighbours, peer) do
    start_time = :os.system_time(:milli_seconds)
    next(peer_id, neighbours, start_time, erb, peer)
  end

  defp next(peer_id, neighbours, start_time, erb, peer) do
    receive do
      {:erb_deliver, {:broadcast_app, max_broadcasts, timeout}} ->
        timeout = if peer_id === 3 do 5 else timeout end
        start_broadcast(peer_id, neighbours, max_broadcasts, timeout, start_time, erb, peer)
    end
  end

  defp start_broadcast(peer_id, neighbours, max_broadcasts, timeout, start_time, erb, peer) do
    send_state = for _ <- 0..neighbours-1, do: 0
    receive_state = for _ <- 0..neighbours-1, do: 0
    spawn(App, :send_peer, [peer_id, neighbours, max_broadcasts, timeout, send_state, self(), start_time])
    receiveP = spawn(App, :receive_peer, [peer_id, neighbours, max_broadcasts, timeout, receive_state, self(), start_time])

    run_broadcast(peer_id, false, false, send_state, receive_state, receiveP, erb, peer)
  end

  defp run_broadcast(peer_id, send_stopped, receive_stopped, send_state, receive_state, receiveP, erb, peer) do
    if send_stopped and receive_stopped do
      end_broadcast(peer_id, Enum.zip(send_state, receive_state), peer)
    else
      {new_send_stopped, new_receive_stopped, new_send_state, new_receive_state} = receive do
        {:stop_send, state} ->
          {true, receive_stopped, state, receive_state}
        {:stop_receive, state} ->
          {send_stopped, true, send_state, state}
        {:erb_deliver, {:send, content}} ->
          # redirect to receive process
          send receiveP, {:send, content}
          {send_stopped, receive_stopped, send_state, receive_state}
        {:erb_broadcast, {:send, peer_id}} ->
          send erb, {:erb_broadcast, {:send, peer_id}}
          {send_stopped, receive_stopped, send_state, receive_state}
      end

      run_broadcast(peer_id, new_send_stopped, new_receive_stopped, new_send_state, new_receive_state, receiveP, erb, peer)
    end
  end

  # prints the state of the peer
  defp end_broadcast(peer_id, state, peer) do
    if peer_id == 3 do
      send peer, {:kill_proc3}
    else
      IO.puts "#{peer_id}: #{inspect(state)}"
    end
  end

end
