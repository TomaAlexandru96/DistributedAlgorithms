# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule Peer do

  def start(peer_id, system, neighbours) do
    pl = spawn(Pl, :start, [peer_id])
    beb = spawn(Beb, :start, [neighbours])
    app = spawn(App, :start, [peer_id, beb, neighbours])

    send system, {:pl_bind, peer_id, pl}
    send pl, {:bind_beb, beb}
    send beb, {:bind, pl, app}
  end

end
