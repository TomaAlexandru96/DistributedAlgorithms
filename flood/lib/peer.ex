defmodule Peer do
  
  def start do
    receive do
      { :neighbours, neighbours } -> next(neighbours, 0)
    end
  end

  defp next(neighbours, count) do
    receive do
      { :hello, message } -> 
        IO.puts "Peer <#{DAC.pid_string(self())}> Message seen = #{count+1})"
        for neighbour <- neighbours do
          send neighbour, { :hello, message }
        end
    end

    next_did_receive_hello(count+1)
  end

  defp next_did_receive_hello(count) do
    receive do
      { :hello, _ } -> 
        IO.puts "Peer <#{DAC.pid_string(self())}> Message seen = #{count+1})"
    end

    Process.sleep(1000)

    next_did_receive_hello(count+1)
  end

end
