# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule Peer do

  def start(peer_id, system) do
    pl = spawn(Pl, :start, [peer_id])
    send system, {:pl_bind, peer_id, pl}

    app = spawn(App, :start, [peer_id, pl])
  end

end
