defmodule Peer do
  def start(id) do
    receive do
      { :neighbours, neighbours} -> next(neighbours, 0, id)
    end
  end

  defp next(neighbours, count, id) do
    {parent, pid} =
      receive do
        { :hello, parent, pid} ->
          for neighbour <- neighbours do
            send neighbour, { :hello, self(), id}
          end
        {parent, pid}
      end

    for neighbour <- neighbours do
      if (neighbour == parent) do
        send neighbour, {:child, 1}
      else
        send neighbour, {:child, 0}
      end
    end

    children =Enum.sum(for _ <- 1..length(neighbours) do
      receive do
        {:child, value} ->  + value;
      end
    end
    )

    sum =
    if (children > 0) do
        Enum.sum(for _ <- 0..children-1  do
          receive do
            {:sum, value} -> + value
          end
        end
        )
    else
        0
    end

    send parent, {:sum, sum+id};



  end

end
