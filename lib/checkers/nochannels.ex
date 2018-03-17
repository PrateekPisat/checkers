defmodule Checkers.NoChannels do
  use Agent

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def save(name, channels) do
    Agent.update __MODULE__, fn state ->
      Map.put(state, name, channels)
    end
  end

  def load(name) do
    Agent.get __MODULE__, fn state ->
      Map.get(state, name)
    end
  end
end
