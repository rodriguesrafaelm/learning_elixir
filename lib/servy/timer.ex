defmodule Servy.Timer do
def remind(message, seconds) do
  spawn(fn ->
  :timer.sleep(seconds * 1000)
  IO.puts(message) end)
end


end

Servy.Timer.remind("Stand Up", 2)
Servy.Timer.remind("Sit Down", 3)
Servy.Timer.remind("Fight, Fight, Fight", 5)


#Enum.map(1..10_000, fn(x) -> spawn(fn -> IO.puts(x*x) end)end)
