# Alexandru Toma (ait15) and Alexandru Dan (ad5915)

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
    # If the operation has been perfomed before, we don't redo it.
    {slot_out, performed} = Enum.reduce(decisions, {slot_out, false}, fn({slot, command0}, {slot_out, performed}) ->
      res = if slot < slot_out and command == command0 and !performed do
        {slot_out + 1, true}
      else
        {slot_out, performed}
      end
      res
    end)

    # If the operation has not been perfomed yet, perform it.
    slot_out = if !performed do
      send state[:database], {:execute, op}
      send client, {:reply, cid, :ok}

      slot_out + 1
    else
      slot_out
    end

    slot_out
  end

  defp propose(state, leaders, slot_in, slot_out, requests, proposals, decisions) do
    window = state[:config][:window]

    if slot_in < slot_out + window and MapSet.size(requests) > 0 do
      # Maka a propsal for all unproposed commands in the window.
      command = Enum.at(requests, 0)
      {requests, proposals} = if decisions[slot_in] == nil do
        requests = MapSet.delete(requests, command)
        proposals = Map.put(proposals, slot_in, command)

        # The leaders need to decide on the proposals.
        Enum.map(leaders, fn(leader) ->
          send leader, {:propose, slot_in, command}
        end)
        {requests, proposals}
      else
        {requests, proposals}
      end

      # When a proposal has been made, move slot_in.
      slot_in = slot_in + 1
      propose(state, leaders, slot_in, slot_out, requests, proposals, decisions)
    else
      {leaders, requests, proposals, slot_in}
    end
  end

  defp handle_decisions(state, slot_out, decisions, proposals, requests) do
    if decisions[slot_out] != nil do

      # If the replica proposed a different command, we need renew
      # the request in order in order for us to agree with the leader's
      # decisions. The decisions should be eliminated from proposals.
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

      # Perform the command. The WINDOW moves to the right, i.e. slot_out
      # increases.
      slot_out = perform(state, decisions[slot_out], decisions, slot_out)
      handle_decisions(state, slot_out, decisions, proposals, requests)
    else
      {state, slot_out, decisions, proposals, requests}
    end
  end

  def next(state, leaders, slot_in, slot_out, requests, proposals, decisions) do
    receive do
      {:client_request, command} ->
        send state[:monitor], {:client_request, state[:config][:server_num]}

        # When a client request arrives, put it in the request set and try to
        # propose it. This ensures liveness for proposals.
        requests = MapSet.put(requests, command)
        {leaders, requests, proposals, slot_in} =
          propose(state, leaders, slot_in, slot_out, requests, proposals, decisions)

        next(state, leaders, slot_in, slot_out, requests, proposals, decisions)

      {:decision, slot, command} ->
        # When a decision was made, we need to execute the command to keep
        # consistent states. The decided command might be exectued later.
        decisions = Map.put(decisions, slot, command)
        {state, slot_out, decisions, proposals, requests} =
          handle_decisions(state, slot_out, decisions, proposals, requests)

        # Since a command might have been decied and proposals updated, we might
        # try to propose a new pending request.
        {leaders, requests, proposals, slot_in} =
          propose(state, leaders, slot_in, slot_out, requests, proposals, decisions)

        next(state, leaders, slot_in, slot_out, requests, proposals, decisions)
    end
  end
end
