# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule Beb do

  def start(neighbours) do
    receive do
      {:bind, pl, app} -> next(pl, app, neighbours)
    end
  end

  defp next(pl, app, neighbours) do
    receive do
      {:pl_deliver, contents} ->
        send app, {:beb_deliver, contents}
      {:beb_broadcast, contents} ->
        for i <- 0..neighbours-1 do
          send pl, {:pl_send, i, contents}
        end
    end

    next(pl, app, neighbours)
  end

end
