defmodule Tests do

  def test1_local() do
    nr_of_peers = 5
    max_broadcasts = 1000
    timeout = 3000
    System1.start(true, nr_of_peers, max_broadcasts, timeout)
  end

  def test2_local() do
    nr_of_peers = 5
    max_broadcasts = 10_000_000
    timeout = 3000
    System1.start(true, nr_of_peers, max_broadcasts, timeout)
  end

  def test3_local() do
    nr_of_peers = 10
    max_broadcasts = 10_000_000
    timeout = 3000
    System1.start(true, nr_of_peers, max_broadcasts, timeout)
  end

  def test1_net() do
    nr_of_peers = 5
    max_broadcasts = 1000
    timeout = 3000
    System1.start(false, nr_of_peers, max_broadcasts, timeout)
  end

  def test2_net() do
    nr_of_peers = 5
    max_broadcasts = 10_000_000
    timeout = 3000
    System1.start(false, nr_of_peers, max_broadcasts, timeout)
  end

  def test3_net() do
    nr_of_peers = 10
    max_broadcasts = 10_000_000
    timeout = 3000

    System1.start(false, nr_of_peers, max_broadcasts, timeout)
  end


end
