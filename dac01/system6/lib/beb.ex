# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule Beb do

  def start(neighbours) do
    receive do
      {:bind, lpl, erb} -> next(lpl, erb, neighbours)
    end
  end

  defp next(lpl, erb, neighbours) do
    receive do
      {:lpl_deliver, contents} ->
        send erb, {:beb_deliver, contents}
      {:beb_broadcast, contents} ->
        for i <- 0..neighbours-1 do
          send lpl, {:lpl_send, i, contents}
        end
    end

    next(lpl, erb, neighbours)
  end

end
