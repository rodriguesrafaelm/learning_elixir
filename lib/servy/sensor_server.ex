defmodule State do
  defstruct sensor_data: %{},
            refresh_interval: :timer.seconds(5)
end

defmodule Servy.SensorServer do

  @server_pid :sensor_server

  use GenServer

  # Client Interface

  def start do
    GenServer.start(__MODULE__, %State{}, name: @server_pid)
  end

  def get_sensor_data do
    GenServer.call @server_pid, :get_sensor_data
  end

  def set_refresh_interval(time_in_ms) do
    GenServer.cast @server_pid, {:set_refresh_interval, time_in_ms}
  end

  # Server Callbacks

  def init(state) do
    initial_state = run_tasks_to_get_sensor_data()
    schedule_refresh(state.refresh_interval)
    {:ok, initial_state}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:set_refresh_interval, time_in_ms}, state) do
    new_state = %{state | refresh_interval: time_in_ms}
    {:noreply, new_state}
  end

  def handle_info(:refresh, state) do
    IO.puts "Atualizando o cache..."
    sensor_data = run_tasks_to_get_sensor_data()
    new_state = %{ state | sensor_data: sensor_data}
    schedule_refresh(state.refresh_interval)
    {:noreply, new_state}
  end

  def handle_info(unexpected, state) do
    IO.puts "Essa mensagem não devia vir pra cá... #{inspect unexpected}"
    {:noreply, state}
  end

  defp schedule_refresh(time_in_ms) do
    Process.send_after(self(), :refresh, time_in_ms)
  end

  defp run_tasks_to_get_sensor_data do
    IO.puts "Pegando dados do sensor.."

    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{snapshots: snapshots, location: where_is_bigfoot}
  end
end
