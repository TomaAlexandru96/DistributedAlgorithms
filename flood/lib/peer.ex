defmodule Peer do
  def start(id) do
    receive do
      { :neighbours, neighbours} -> next(neighbours, 0, id)
    end
  end

  defp next(neighbours, count, id) do
    parent =
      receive do
        { :hello, parent, pid} ->
          IO.puts "Parent #{parent} Peer #{id} Message seen = #{count+1})"
          for neighbour <- neighbours do
            send neighbour, { :hello, id, self()}
          end
        pid
      end
    Process.sleep(1000)
    for neighbour <- neighbours do
      if (neighbour == parent) do
        send neighbour, {:child, 1}
      else
        send neighbour, {:child, 0}
      end
    end

    children =length(for _ <- 1..length(neighbours) do
      receive do
        {:child, value} ->  + value;
      end
    end
    )
    IO.puts "Peer #{id} Children #{inspect children}"
  end

  # defp next_did_receive_hello(count, id, parent) do
  #   receive do
  #     { :hello, pid} ->
  #       IO.puts "Parent #{parent} Peer #{id} Message seen = #{count+1})"
  # end
  #
  #
  #   next_did_receive_hello(count+1, id, parent)
  # end

end
