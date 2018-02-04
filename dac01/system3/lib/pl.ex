# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule Pl do

  def start(peer_id) do
    receive do
      {:bind, peers_pl} -> next_bind(peer_id, peers_pl)
    end
  end

  defp next_bind(peer_id, peers_pl) do
    receive do
      {:bind_beb, beb} -> next(beb, peer_id, peers_pl)
    end
  end

  defp next(beb, peer_id, peers_pl) do
    receive do
      {:pl_send, peer_index, content} -> send get(peer_index, peers_pl), content
      any -> redirect_to_beb(beb, any)
    end
    next(beb, peer_id, peers_pl)
  end

  defp redirect_to_beb(beb, msg) do
    send beb, {:pl_deliver, msg}
  end

  defp get(id, peers_pl) do
    [{peer_id, pl} | _] = Enum.filter(peers_pl, fn({peer_id, pl}) -> peer_id === id end)
    pl
  end

end
