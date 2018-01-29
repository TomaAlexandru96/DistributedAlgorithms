defmodule ClientServer do
  
  def main do
    clients = for k <- 1..5, do: spawn(Client, :start, [k])
    s = spawn(Server, :start, [])

    for c <- clients, do:
      send c, { :bind, s }
  end

end
