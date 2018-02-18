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

  defp perform(state, {client, cid, op}, decisions, slot_out) do
    prev_slot_out = slot_out
    slot_out = Enum.reduce(decisions, slot_out, fn({slot, {_, _, op0}}, slot_out) ->
      slot_out = if slot < slot_out or op0 == :reconfig do
        slot_out + 1
      else
        slot_out
      end
      slot_out
    end)

    if slot_out == prev_slot_out do
      # Update State...
      IO.puts "Update state ples..."

      {state, slot_out}
    end

    {state, slot_out}
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
      {:request, command} ->
        requests = MapSet.put(requests, command)
        next(state, leaders, slot_in, slot_out, requests, proposals, decisions)
      {:decision, slot, command} ->
        decisions = Map.put(decisions, slot, command)
        {state, slot_out, decisions, proposals, requests} = propose_decision(state, slot_out, decisions, proposals, requests)
    end
  end
end
