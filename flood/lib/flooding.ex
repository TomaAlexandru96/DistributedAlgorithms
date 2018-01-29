defmodule Flooding do

  @moduledoc """
    Flooding Point
  """

  def main do
    DAC.node_spawn(:"127.0.0.1", 1, Flooding, :start, [10])
  end

  def start(number_of_peers) do
    peers = for _ <- 0..number_of_peers-1, do: 
              spawn(Peer, :start, []) 

    for i <- 0..number_of_peers-1 do
      send Enum.at(peers, i), { :neighbours, peers }
    end

    send Enum.at(peers, 0), { :hello, "From Flood" }
  end

end
