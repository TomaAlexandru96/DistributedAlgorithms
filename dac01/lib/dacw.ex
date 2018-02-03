# Alexandru Toma (ait15) and Andrei Isaila (ii515)

defmodule Dacw do

  def main() do
    start_system1(true)
  end

  # Local tests
  # Test 1
  # nr_of_peers = 5
  # max_broadcasts = 1000
  # timeout = 3000
  # Output:
  # 0: [{1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}]
  # 2: [{1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}]
  # 3: [{1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}]
  # 4: [{1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}]
  # 1: [{1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}, {1000, 1000}]
  #
  # Test 2
  # nr_of_peers = 5
  # max_broadcasts = 10_000_000
  # timeout = 3000
  # Output:
  # 1: [{93154, 87113}, {93154, 93153}, {93154, 146710}, {93154, 107294}, {93154, 53965}]
  # 4: [{53966, 87111}, {53966, 93151}, {53966, 146704}, {53966, 107292}, {53966, 53964}]
  # 2: [{146714, 87109}, {146714, 93149}, {146714, 146697}, {146714, 107284}, {146714, 53961}]
  # 3: [{107296, 87031}, {107296, 93072}, {107296, 146480}, {107296, 107147}, {107296, 53883}]
  # 0: [{87114, 87040}, {87114, 93081}, {87114, 146504}, {87114, 107166}, {87114, 53893}]
  #
  # Test 3
  # nr_of_peers = 10
  # max_broadcasts = 10_000_000
  # timeout = 3000
  # Output:
  # 18705}, {18636, 18635}, {18636, 13924}, {18636, 20476}, {18636, 18589}, {18636, 18250}, {18636, 12688}, {18636, 16539}, {18636, 11876}, {18636, 18228}]
  defp start_system1(is_local) do
    nr_of_peers = 5
    max_broadcasts = 1000
    timeout = 3000
    spawn(System1, :start, [is_local, nr_of_peers, max_broadcasts, timeout])

    Process.sleep(timeout)

    nr_of_peers = 5
    max_broadcasts = 10_000_000
    timeout = 3000
    spawn(System1, :start, [is_local, nr_of_peers, max_broadcasts, timeout])

    Process.sleep(timeout)

    nr_of_peers = 10
    max_broadcasts = 10_000_000
    timeout = 3000
    spawn(System1, :start, [is_local, nr_of_peers, max_broadcasts, timeout])

  end

end
