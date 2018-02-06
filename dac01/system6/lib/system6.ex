# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule System6 do

  def main() do
    send_percentage = 50
    start_test3(true, send_percentage)
  end

  # Local tests
  # Starting local with nr_of_peers: 5, max_broadcasts: 1000, timeout: 3000
  #
  # 0: [{1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}]
  # 4: [{1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}]
  # 2: [{1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}]
  # 3: [{1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}]
  # 1: [{1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}]
  #
  # On Docker with 5 containers
  # container0                | 1: [{1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}]
  # container0                | 2: [{1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}]
  # container0                | 4: [{1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}]
  # container0                | 3: [{1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}]
  # container0                | 0: [{1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}]
  defp start_test1(is_local, send_percentage) do
    nr_of_peers = 5
    max_broadcasts = 1000
    timeout = 3000
    start(is_local, nr_of_peers, max_broadcasts, timeout, send_percentage)
  end

  # Starting local with nr_of_peers: 5, max_broadcasts: 10000000, timeout: 3000
  #
  # 3: [{224357, 2668}, {224357, 2763}, {224357, 1998}, {224357, 2389}, {224357, 2625}]
  # 0: [{197199, 1676}, {197199, 1868}, {197199, 969}, {197199, 1197}, {197199, 1191}]
  # 4: [{199766, 3353}, {199766, 3421}, {199766, 2595}, {199766, 3105}, {199766, 3653}]
  # 2: [{193652, 2102}, {193652, 2157}, {193652, 1355}, {193652, 1666}, {193652, 1720}]
  # 1: [{201851, 2134}, {201851, 2187}, {201851, 1355}, {201851, 1702}, {201851, 1760}]
  #
  # On Docker with 5 containers
  # container0                | 1: [{23597, 2812}, {23597, 14742}, {23597, 3730}, {23597, 3449}, {23597, 4046}]
  # container0                | 0: [{26064, 19705}, {26064, 3222}, {26064, 7707}, {26064, 4093}, {26064, 4288}]
  # container0                | 4: [{18468, 20016}, {18468, 14729}, {18468, 17086}, {18468, 16692}, {18468, 16166}]
  # container0                | 3: [{24048, 2039}, {24048, 1393}, {24048, 7237}, {24048, 20124}, {24048, 2264}]
  # container0                | 2: [{26537, 14824}, {26537, 13261}, {26537, 26418}, {26537, 4550}, {26537, 12530}]
  defp start_test2(is_local, send_percentage) do
    nr_of_peers = 5
    max_broadcasts = 10_000_000
    timeout = 3000
    start(is_local, nr_of_peers, max_broadcasts, timeout, send_percentage)
  end

  # Starting local with nr_of_peers: 10, max_broadcasts: 10000000, timeout: 3000
  #
  # 0: [{80307, 174}, {80307, 234}, {80307, 232}, {80307, 154}, {80307, 165}, {80307, 160}, {80307, 153}, {80307, 154}, {80307, 159}, {80307, 170}]
  # 1: [{80368, 246}, {80368, 360}, {80368, 358}, {80368, 205}, {80368, 225}, {80368, 225}, {80368, 204}, {80368, 205}, {80368, 230}, {80368, 251}]
  # 3: [{58486, 213}, {58486, 313}, {58486, 310}, {58486, 181}, {58486, 198}, {58486, 198}, {58486, 180}, {58486, 181}, {58486, 198}, {58486, 213}]
  # 2: [{83414, 223}, {83414, 331}, {83414, 328}, {83414, 191}, {83414, 209}, {83414, 208}, {83414, 191}, {83414, 191}, {83414, 208}, {83414, 227}]
  # 9: [{58431, 256}, {58431, 378}, {58431, 376}, {58431, 215}, {58431, 235}, {58431, 236}, {58431, 214}, {58431, 215}, {58431, 242}, {58431, 265}]
  # 6: [{59011, 198}, {59011, 287}, {59011, 285}, {59011, 167}, {59011, 183}, {59011, 183}, {59011, 166}, {59011, 167}, {59011, 182}, {59011, 194}]
  # 7: [{59010, 206}, {59010, 300}, {59010, 298}, {59010, 175}, {59010, 191}, {59010, 191}, {59010, 174}, {59010, 174}, {59010, 191}, {59010, 204}]
  # 8: [{58399, 229}, {58399, 346}, {58399, 344}, {58399, 197}, {58399, 213}, {58399, 214}, {58399, 196}, {58399, 197}, {58399, 215}, {58399, 232}]
  # 5: [{75825, 151}, {75825, 196}, {75825, 195}, {75825, 135}, {75825, 142}, {75825, 140}, {75825, 134}, {75825, 134}, {75825, 140}, {75825, 143}]
  # 4: [{82906, 120}, {82906, 138}, {82906, 138}, {82906, 112}, {82906, 110}, {82906, 110}, {82906, 112}, {82906, 112}, {82906, 110}, {82906, 111}]

  # On Docker with 5 containers
  # container0                |
  # container0                | 19:43:01.036 [warn]  ** Can not start PeerSystem1::start,[5] on :"node6@container6.localdomain" **
  # container0                |
  # container0                |
  # container0                | 19:43:01.036 [warn]  ** Can not start PeerSystem1::start,[6] on :"node7@container7.localdomain" **
  # container0                |
  # container0                |
  # container0                | 19:43:01.036 [warn]  ** Can not start PeerSystem1::start,'\a' on :"node8@container8.localdomain" **
  # container0                |
  # container0                |
  # container0                | 19:43:01.036 [warn]  ** Can not start PeerSystem1::start,'\b' on :"node9@container9.localdomain" **
  # container0                |
  # container0                |
  # container0                | 19:43:01.036 [warn]  ** Can not start PeerSystem1::start,'\t' on :"node10@container10.localdomain" **
  # container0                |
  # container0                | 0: [{7912, 6965}, {7912, 5127}, {7912, 8546}, {7912, 5465}, {7912, 5479}, {7912, 0}, {7912, 0}, {7912, 0}, {7912, 0}, {7912, 0}]
  # container0                | 1: [{7414, 4649}, {7414, 4467}, {7414, 4470}, {7414, 4199}, {7414, 4002}, {7414, 0}, {7414, 0}, {7414, 0}, {7414, 0}, {7414, 0}]
  # container0                | 2: [{10626, 6648}, {10626, 6016}, {10626, 8733}, {10626, 5796}, {10626, 5109}, {10626, 0}, {10626, 0}, {10626, 0}, {10626, 0}, {10626, 0}]
  # container0                | 3: [{7225, 7377}, {7225, 7003}, {7225, 9550}, {7225, 6664}, {7225, 5717}, {7225, 0}, {7225, 0}, {7225, 0}, {7225, 0}, {7225, 0}]
  # container0                | 4: [{7446, 7912}, {7446, 6856}, {7446, 9147}, {7446, 7124}, {7446, 7446}, {7446, 0}, {7446, 0}, {7446, 0}, {7446, 0}, {7446, 0}]
  defp start_test3(is_local, send_percentage) do
    nr_of_peers = 10
    max_broadcasts = 10_000_000
    timeout = 3000
    start(is_local, nr_of_peers, max_broadcasts, timeout, send_percentage)
  end

  def start(is_local, nr_of_peers, max_broadcasts, timeout, send_percentage) do
    IO.puts "Starting #{if is_local do "local" else "on docker" end} with nr_of_peers: #{nr_of_peers}, max_broadcasts: #{max_broadcasts}, timeout: #{timeout}"
    IO.puts ""

    for i <- 1..nr_of_peers do
      peer = if is_local do
        spawn(Peer, :start, [i-1, self(), nr_of_peers, send_percentage])
      else
        Node.spawn(:'node#{i}@container#{i}.localdomain', Peer, :start, [i-1, self(), nr_of_peers, send_percentage])
      end
    end

    peers_lpl = for _ <- 1..nr_of_peers do
      receive do
        {:lpl_bind, peer_id, lpl} -> {peer_id, lpl}
      end
    end

    # send neighbours of lpl
    for {peer_id, lpl} <- peers_lpl do
      send lpl, {:bind, peers_lpl}
    end

    # start broadcast
    for {peer_id, lpl} <- peers_lpl do
      send lpl, {:broadcast_app, max_broadcasts, timeout}
    end
  end

end
