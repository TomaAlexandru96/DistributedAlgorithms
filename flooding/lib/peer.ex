defmodule Peer do

  def start do
    receive do
      {:bind, peers} -> next(peers, 0, False)
    end
  end

  defp next(peers, count, first_seen) do
    receive do 
      {:hello, msg, parent} ->
        send parent, {:child}

        children = 0
        if first_seen == False do
          for peer <- peers do
            send peer, {:hello, "From Peer", self()}
          end

          for i <- 0..length(peers) do
            receive do
              {:child} -> IO.puts "#{DAC.pid_string(self())}" #children + 1
            end
          end
        end

        IO.puts "Peer #{DAC.self_string()} Parent #{DAC.pid_string(parent)} Children #{children}\
                 Messages seen = #{count + 1} Message is #{msg}"

        Process.sleep(1000 + DAC.random(500))
        next(peers, count + 1, True)
    end
  end
end
