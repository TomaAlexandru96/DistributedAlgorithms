# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule Lpl do

  def start(peer_id, send_percentage) do
    receive do
      {:bind, peers_lpl} -> next_bind(peer_id, peers_lpl, send_percentage)
    end
  end

  defp next_bind(peer_id, peers_lpl, send_percentage) do
    receive do
      {:bind_beb, beb} -> next(beb, peer_id, peers_lpl, send_percentage)
    end
  end

  defp next(beb, peer_id, peers_lpl, send_percentage) do
    receive do
      {:lpl_send, peer_index, content} ->
        if get_should_send(send_percentage) do
          send get(peer_index, peers_lpl), content
        end
      {:broadcast_app, max_broadcasts, timeout} ->
        redirect_to_beb(beb, {:broadcast_app, max_broadcasts, timeout})
      any ->
        if get_should_send(send_percentage) do
          redirect_to_beb(beb, any)
        end
    end
    next(beb, peer_id, peers_lpl, send_percentage)
  end

  defp get_should_send(send_percentage) do
    random = Enum.random(0..10000) / 10000
    send_percentage / 100 >= random
  end

  defp redirect_to_beb(beb, msg) do
    send beb, {:lpl_deliver, msg}
  end

  defp get(id, peers_lpl) do
    [{peer_id, lpl} | _] = Enum.filter(peers_lpl, fn({peer_id, lpl}) -> peer_id === id end)
    lpl
  end

end
