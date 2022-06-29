defmodule Recurse do
  def somar([head | tail], soma) do
    soma = soma + head
    somar(tail, soma)
  end
  def somar(_, soma), do: soma
end

IO.puts(Recurse.somar([1,2,3], 0))
