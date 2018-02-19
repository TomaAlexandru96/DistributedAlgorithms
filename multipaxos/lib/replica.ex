defmodule Replica do
  def start(config, database, monitor) do
    receive do
      {:bind, leaders} ->
        state = %{
          :config => config,
          :database => database,
          :monitor => monitor
        }
        next(state, leaders, 1, 1, MapSet.new, Map.new, Map.new)
    end
  end

  defp perform(state, {client, cid, op} = command, decisions, slot_out) do
    # IO.puts inspect decisions
    {slot_out, performed} = Enum.reduce(decisions, {slot_out, false}, fn({slot, {_, _, op0} = command0}, {slot_out, performed}) ->
      res = if ((slot < slot_out and command == command0) or op0 == :reconfig) and !performed do
        {slot_out + 1, true}
      else
        {slot_out, performed}
      end
      res
    end)

    {state, slot_out} = if !performed do
      # TODO: look at leader change operation...
      send state[:database], {:execute, op}
      slot_out = slot_out + 1

      send client, {:reply, cid, :ok}

      {state, slot_out}
    else
      {state, slot_out}
    end

    {state, slot_out}
  end

  defp propose(state, leaders, slot_in, slot_out, requests, proposals, decisions) do
    window = state[:config][:window]

    if slot_in < slot_out + window and MapSet.size(requests) > 0 do

    # Change set of leaders

    #   leaders = if decisions[slot_in - window] != nil do
    #     {_, _, op} = decisions[slot_in - window]
    #     leaders = if op == :reconfig do
    #       # TODO: op.leaders
    #       leaders
    #     else
    #       leaders
    #     end
    #     leaders
    #   else
    #     leaders
    #   end

      command = Enum.at(requests, 0)
      {requests, proposals} = if decisions[slot_in] == nil do
        requests = MapSet.delete(requests, command)
        proposals = Map.put(proposals, slot_in, command)
        Enum.map(leaders, fn(leader) ->
          # IO.puts inspect {slot_in, slot_out, command}
          send leader, {:propose, slot_in, command}
        end)
        {requests, proposals}
      else
        {requests, proposals}
      end

      slot_in = slot_in + 1
      propose(state, leaders, slot_in, slot_out, requests, proposals, decisions)
    else
      {leaders, requests, proposals, slot_in}
    end
  end

  defp propose_decision(state, slot_out, decisions, proposals, requests) do
    if decisions[slot_out] != nil do

      # if there is a decision in slot_out, update proposals and requests
      {proposals, requests} = if proposals[slot_out] != nil do
        requests = if proposals[slot_out] != decisions[slot_out] do
          MapSet.put(requests, proposals[slot_out])
        else
          requests
        end
        proposals = Map.delete(proposals, slot_out)
        {proposals, requests}
      else
        {proposals, requests}
      end

      # perform
      {state, slot_out} = perform(state, decisions[slot_out], decisions, slot_out)
      propose_decision(state, slot_out, decisions, proposals, requests)
    else
      {state, slot_out, decisions, proposals, requests}
    end
  end

  def next(state, leaders, slot_in, slot_out, requests, proposals, decisions) do
    receive do
      {:client_request, command} ->
        send state[:monitor], {:client_request, state[:config][:server_num]}

        # IO.puts (inspect requests)
        requests = MapSet.put(requests, command)
        {leaders, requests, proposals, slot_in} =
          propose(state, leaders, slot_in, slot_out, requests, proposals, decisions)

        next(state, leaders, slot_in, slot_out, requests, proposals, decisions)

      {:decision, slot, command} ->
        decisions = Map.put(decisions, slot, command)
        {state, slot_out, decisions, proposals, requests} =
          propose_decision(state, slot_out, decisions, proposals, requests)
        {leaders, requests, proposals, slot_in} =
          propose(state, leaders, slot_in, slot_out, requests, proposals, decisions)

        next(state, leaders, slot_in, slot_out, requests, proposals, decisions)
    end
  end
end
