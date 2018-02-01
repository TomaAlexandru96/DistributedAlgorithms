defmodule Flooding do

  @moduledoc """
    Flooding Point
  """

  def main do
    spawn(Flooding, :start, [10])
  end

  def start(number_of_peers) do

    peers = for i <- 0..number_of_peers-1, do:
        spawn(Peer, :start, [i])

    bind(peers, 0, [1, 6])
    bind(peers, 1, [0, 2, 3])
    bind(peers, 2, [1, 3, 4])
    bind(peers, 3, [1, 2, 5])
    bind(peers, 4, [2])
    bind(peers, 5, [3])
    bind(peers, 6, [0, 7])
    bind(peers, 7, [6, 8, 9])
    bind(peers, 8, [7, 9])
    bind(peers, 9, [7, 8]) # peer 9's neighbours are peers 7 andx

    send Enum.at(peers, 0), { :hello, self(), "Generator" }
    receive do
      {:sum, value} -> IO.puts "#{value}"
    end
  end

  defp bind(peers, peer, neighbours) do
    send Enum.at(peers, peer), {:neighbours,
                                Enum.map(neighbours, fn(x)-> Enum.at(peers, x) end)}
  end

end
