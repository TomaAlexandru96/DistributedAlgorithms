# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule Dacw do

  def main() do
    start_system1()
  end

  defp start_system1() do
    nr_of_peers = 5
    max_broadcasts = 1000
    timeout = 3000
    spawn(System1, :start, [true, nr_of_peers, max_broadcasts, timeout])
  end

end
