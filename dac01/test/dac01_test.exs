defmodule Dac01Test do
  use ExUnit.Case
  doctest Dac01

  test "greets the world" do
    assert Dac01.hello() == :world
  end

  test "test1" do
    nr_of_peers = 5
    max_broadcasts = 1000
    timeout = 3000
    spawn(DASystem, :start, [nr_of_peers, max_broadcasts, timeout])
  end
end
