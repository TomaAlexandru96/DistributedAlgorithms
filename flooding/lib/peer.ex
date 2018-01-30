defmodule Peer do

  def start do
    receive do
      {:bind, peers} -> next(peers, 0)
    end
  end

  defp next(peers, count) do
    receive do
      {:hello, msg} ->
        IO.puts "Peer #{DAC.self_string()} Messages seen = #{count + 1}"
        for peer <- peers do
          send peer, {:hello, "From Peer", DAC.self_string()}
        end
      {:hello, msg, parent} ->
        IO.puts "Peer #{DAC.self_string()} Parent #{parent} Messages seen = #{count + 1}"
        for peer <- peers do
          send peer, {:hello, "From Peer", DAC.self_string()}
        end
    end

    Process.sleep(1000)
    Process.sleep(DAC.random(500))

    next_2(count + 1)
  end

  defp next_2(count) do
    receive do
      {:hello, msg, parent} ->
        IO.puts "Peer #{DAC.self_string()} Parent #{parent} Messages seen = #{count + 1}"
    end

    Process.sleep(1000)
    Process.sleep(DAC.random(500))

    next_2(count + 1)
  end

end
