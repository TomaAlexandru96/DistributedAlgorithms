# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule Peer do

  def start(peer_id, system, neighbours, send_percentage) do
    lpl = spawn(Lpl, :start, [peer_id, send_percentage])
    beb = spawn(Beb, :start, [neighbours])
    erb = spawn(Erb, :start, [])
    app = spawn(App, :start, [peer_id, erb, neighbours, self()])

    send system, {:lpl_bind, peer_id, lpl}
    send lpl, {:bind_beb, beb}
    send beb, {:bind, lpl, erb}
    send erb, {:bind, beb, app}

    receive do
      {:kill_proc3} ->
        Process.exit(lpl, :kill)
        Process.exit(beb, :kill)
        Process.exit(erb, :kill)
        Process.exit(app, :kill)
        Process.exit(self(), :kill)
    end
  end

end
