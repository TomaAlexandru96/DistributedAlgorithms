# Alexandru Toma (ait15) and Alexandru Dan (ad5915)
# distributed algorithms, n.dulay, 2 feb 18
# multi-paxos, configuration parameters v1

defmodule Configuration do

def version 1 do	# configuration 1
  %{
  debug_level:  0, 	# debug level
  docker_delay: 5_000,	# time (ms) to wait for containers to start up

  max_requests: 500,   	# max requests each client will make
  client_sleep: 5,	# time (ms) to sleep before sending new request
  client_stop:  10_000,	# time (ms) to stop sending further requests
  n_accounts:   100,	# number of active bank accounts
  max_amount:   1000,	# max amount moved between accounts

  print_after:  1_000,	# print transaction log summary every print_after msecs
  leader_failures: 0,   # number of leader failures to happen in the system
  acceptor_failures: 0, # number of acceptor failures to happen in the system
  replica_failures: 0,  # number of replica failures to happen in the system

  # add your own here
  window: 5,
  }
end

def version 2 do
 config = version 1
 Map.put config, :client_sleep, 2
 Map.put config, :max_requests, 10_000
end

def version 3 do
 config = version 1
 Map.put config, :client_sleep, 2
 Map.put config, :window, 100
 Map.put config, :max_requests, 10_000
end

def version 4 do
 config = version 1
 Map.put config, :client_sleep, 2
 Map.put config, :window, 1000
 Map.put config, :max_requests, 500
end

# All of these should be ran with 7 servers

def version 5 do # should work
 config = version 1
 Map.put config, :acceptor_failures, 3
end

def version 6 do # should not work
 config = version 1
 Map.put config, :acceptor_failures, 4
end

def version 7 do # should work
 config = version 1
 Map.put config, :leader_failures, 6
end

def version 8 do # should work
 config = version 1
 Map.put config, :replica_failures, 6
end

end # module -----------------------
