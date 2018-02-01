# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule Dac01 do

  def main() do
    nr_of_peers = 5
    max_broadcasts = 1000
    timeout = 3000
    spawn(DASystem, :start, [nr_of_peers, max_broadcasts, timeout])
  end

end
