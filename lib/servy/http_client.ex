defmodule Servy.HttpClient do


def send_request(request, port) do
  some_host_in_net = 'localhost' # to make it runnable on one machine
  {:ok, socket} = :gen_tcp.connect(some_host_in_net, port, [:binary, packet: :raw, active: false])
  :ok = :gen_tcp.send(socket, request)
  {:ok, response} = :gen_tcp.recv(socket, 0)
  :ok = :gen_tcp.close(socket)
  response
end

end

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

spawn(fn -> Servy.HttpServer.start(5000) end)
:timer.sleep(2000)
response = Servy.HttpClient.send_request(request, 5000)
IO.puts(response)
