defmodule Servy.PledgeServer do

  @server_process :pledge_server

  #Client interface
  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  # State é passado para o init() pela função start
  def start() do
    IO.puts "Starting pledge server..."
    GenServer.start(__MODULE__, %State{}, name: @server_process)
  end

  def create_pledge(name, amount) do
    GenServer.call(@server_process, {:create_pledge, name, amount})

  end

  def recent_pledges() do
    # Retorna as 3 mais recentes.
    GenServer.call(@server_process, :recent_pledges)
  end

  def total_pledged() do
    GenServer.call(@server_process, :total_pledged)

  end

  def clear do
    GenServer.cast(@server_process, :clear)
  end

  def set_cache_size(size) do
    GenServer.cast(@server_process, {:set_cache_size, size})
  end


    #Server callbacks


    # valor de State no inicio do programa
def init(state) do
  pledges = fetch_recent_pledges_from_service()
  new_state = %{state | pledges: pledges}
  {:ok, new_state}
end


def handle_cast(:clear, state) do
  {:noreply, %{ state | pledges: []}}
end

# def handle_cast({:set_cache_size, size}, state) do
#   {:noreply, %{state | cache_size: size}}
# end

def handle_cast({:set_cache_size, size}, state) do
  resized_cache = Enum.take(state.pledges, size)
  new_state = %{state | cache_size: size, pledges: resized_cache}
  {:noreply, new_state}
end

def handle_call(:total_pledged, _from, state) do
  total = Enum.map(state.pledges, &elem(&1, 1)) |> Enum.sum()
  {:reply, total, state}
end

def handle_call(:recent_pledges, _from, state) do
  {:reply, state.pledges, state}
end

def handle_call({:create_pledge, name, amount}, _from, state) do
  {:ok, id} = send_pledge_to_service(name, amount)
  most_recent_pledges = Enum.take(state.pledges, state.cache_size - 1)
  cached_pledges = [ {name, amount} | most_recent_pledges]
  new_state = %{state | pledges: cached_pledges}
  {:reply, id, new_state}
  end

def handle_info(message, state) do
  IO.puts("Can't touch this #{inspect message}")
  {:noreply, state}
end


def send_pledge_to_service(_name, _amount) do
  {:ok, "pledge-#{:rand.uniform(1000)}"}
  end


def fetch_recent_pledges_from_service do
  [{"Maria", 25}, {"Pedro", 30}]
end

end


alias Servy.PledgeServer

{:ok, pid} = PledgeServer.start()

send pid, {:stop, "hammertimer"}

PledgeServer.set_cache_size(4)



IO.inspect PledgeServer.create_pledge("larry", 10)

# PledgeServer.clear()

# IO.inspect PledgeServer.create_pledge("moe", 20)
# IO.inspect PledgeServer.create_pledge("curly", 30)
# IO.inspect PledgeServer.create_pledge("daisy", 40)
# IO.inspect PledgeServer.create_pledge("grace", 50)

IO.inspect PledgeServer.recent_pledges()
