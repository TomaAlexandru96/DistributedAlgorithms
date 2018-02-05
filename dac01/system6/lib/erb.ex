# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule Erb do

  def start(neighbours) do
    receive do
      {:bind, beb, app} -> next(beb, app, neighbours)
    end
  end

  defp next(beb, app, neighbours) do
    receive do
      {:beb_deliver, contents} ->
        send app, {:erb_deliver, contents}
      {:erb_broadcast, contents} ->
        send beb, {:beb_broadcast, contents}
    end

    next(beb, app, neighbours)
  end

end
