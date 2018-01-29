defmodule Client do
  
  def start(k) do
    receive do 
        { :bind, s } -> next(s, k) 
      end
  end

  defp next(s, k) do
    send s, { :circle, 1.0, self() }
    receive do 
      { :result, area } -> IO.puts "#{k}: Area is #{area}"
    end
    Process.sleep(1000)
    Process.sleep(Enum.random(0..2000))
    next(s, k)
  end

end
