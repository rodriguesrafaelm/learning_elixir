defmodule Servy.Parser do

  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\r\n\r\n")

    [request_line | header_lines] = String.split(top, "\r\n")

    [metodo, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines, %{})

    params = parse_params(headers["Content-Type"], params_string)


    %Conv{method: metodo, path: path, params: params, headers: headers}
  end

  def parse_headers([head | tail], headers) do
    head = String.trim(head)
    [key, value] = String.split(head, (": "))
    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
  end

  def parse_headers([], headers), do: headers


  @doc """
  Parses the given param string of the form `key1=value1&key2=value2`
  into a map with corresponding keys and values

  #examples
    iex> params_string = "name=Baloo&type=Brown"
    iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
    %{"name" => "Baloo", "type" => "Brown"}
    iex> Servy.Parser.parse_params("multpart/form-data", params_string)
    %{}
  """

  def parse_params("application/json", params_string) do
    Poison.Parser.parse!(params_string, %{})
  end

  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string
    |> String.trim()
    |> URI.decode_query()
  end

  def parse_params(_, _), do: %{}

end