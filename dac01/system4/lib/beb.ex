# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule Beb do

  def start(neighbours) do
    receive do
      {:bind, lpl, app} -> next(lpl, app, neighbours)
    end
  end

  defp next(lpl, app, neighbours) do
    receive do
      {:lpl_deliver, contents} ->
        send app, {:beb_deliver, contents}
      {:beb_broadcast, contents} ->
        for i <- 0..neighbours-1 do
          send lpl, {:lpl_send, i, contents}
        end
    end

    next(lpl, app, neighbours)
  end

end
