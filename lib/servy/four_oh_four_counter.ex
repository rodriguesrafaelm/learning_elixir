defmodule Servy.FourOhFourCounter do

  @processo_do_counter :four_oh_four_counter
  # Client Interface

  def start do
    IO.puts "Starting the 404 counter..."
    GenServer.start(__MODULE__, %{}, @processo_do_counter)
  end

  def bump_count(path) do
    GenServer.call(@processo_do_counter, {:bump_count, path})
  end

  def get_counts do
    GenServer.call(@processo_do_counter, :get_counts)
  end

  def get_count(path) do
    GenServer.call(@processo_do_counter, {:get_count, path})
  end

  def reset do
    GenServer.cast(@processo_do_counter, :reset)
  end

  # Helper Functions



  # Server



  def handle_call({:bump_count, path}, _from, state) do
    new_state = Map.update(state, path, 1, &(&1 + 1))
    {:reply, :ok, new_state}
  end

  def handle_call(:get_counts, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:get_count, path}, _from, state) do
    count = Map.get(state, path, 0)
    {:reply, count, state}
  end

  def handle_cast(:reset, _state) do
    {:noreply, %{}}
  end
end
