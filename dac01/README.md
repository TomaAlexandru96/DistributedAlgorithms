These instructions will demonstrate how to run the elixir systems.


1: cd into the system you want to run
2: make compile
3: LOCAL : make run PEERS=(5 or 10) MAX=(1..MAX_INT) T=(1..MAX_INT)

   ON DOCKER: make up PEERS=(5 or 10) MAX=(1..MAX_INT) T=(1..MAX_INT)

NOTE1: if you do not specify one of the parameters the default values are 5, 3000 and 1000.

NOTE2: for Systems 4-6 you can add the parameter P=(0..100) which defaults to 100. 

MAX=max_broadcasts
T=timeout
P=Percentage of correctly sent messeges



