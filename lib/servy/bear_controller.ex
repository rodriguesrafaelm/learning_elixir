defmodule Servy.BearController do

  alias Servy.Wildthings
  alias Servy.Bear
  import Servy.View, only: [render: 3]


  def index(conv) do
    bears =
    Wildthings.list_bears()
    |> Enum.sort(&Bear.order_asc_by_name/2)

   render(conv, "index.eex", bears: bears)
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    render(conv, "show.eex", bear: bear)
  end

  def create(conv, %{"name" => name, "type" => type} = _params) do
    %{conv | status: 201, resp_body: "Criou um urso com o nome #{name} e do tipo #{type}"}
  end

  def delete(conv, _params) do
    %{conv | status: 403, resp_body: "Não foi possivel deletar o urso"}
  end
end
