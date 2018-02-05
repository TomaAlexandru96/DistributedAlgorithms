# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule Erb do

  def start() do
    receive do
      {:bind, beb, app} -> next(beb, app, MapSet.new, 0)
    end
  end

  defp next(beb, app, delivered, count_id) do
    receive do
      {:erb_broadcast, contents} ->
        send beb, {:beb_broadcast, {contents, count_id}}
        next(beb, app, delivered, count_id + 1)
      {:beb_deliver, {content, _} = m} ->
        if MapSet.member? delivered, m do
          next(beb, app, delivered, count_id)
        else
          send app, {:erb_deliver, content}
          send beb, {:beb_broadcast, m}
          next(beb, app, MapSet.put(delivered, m), count_id)
        end

      # special case
      {:beb_deliver, {:broadcast_app, max_broadcasts, timeout}} ->
        send app, {:erb_deliver, {:broadcast_app, max_broadcasts, timeout}}
        next(beb, app, delivered, count_id)
    end
  end

end
