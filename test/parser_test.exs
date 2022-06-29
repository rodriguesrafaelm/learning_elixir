defmodule ParserTest do
  use ExUnit.Case
  alias Servy.Parser

  test "testing header parser" do
    header_lines = ["A: 1", "B: 2"]

    headers = Parser.parse_headers(header_lines, %{})

    assert headers == %{"A" => "1", "B" => "2"}

  end

end
