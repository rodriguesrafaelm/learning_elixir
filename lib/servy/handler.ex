
defmodule Servy.Handler do

  @moduledoc """
  Lidar com requisições HTTP
  """
  alias Servy.BearController
  alias Servy.Conv
  alias Servy.VideoCam
  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.FileHandler
  import Servy.Parser, only: [parse: 1]
  import Servy.Plugins, only: [track: 1, rewrite_path: 1, log: 1]
  import Servy.View, only: [render: 3]
  @doc """
  Transforma requisições HTTP em respostas HTTP.
  """
  def handle(request) do
    request
    |> parse()
    |> rewrite_path()
    #|> log()
    |> route()
    |> track()
    |> put_content_length()
    |> format_response()
  end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    Servy.PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    Servy.PledgeController.index(conv)
  end


  def route(%Conv{ method: "GET", path: "/sensors" } = conv) do
    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    render(conv, "sensors.eex", snapshots: snapshots, location: where_is_bigfoot)
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time } = conv) do
    time |> String.to_integer() |> :timer.sleep()
    %{conv | status: 200, resp_body: "Awake!"}
  end

  def route(%Conv{ method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/bears" } = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{ method: "GET", path: "/bears/" <> id } = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    pages_path =
      @pages_path
      |> Path.join("page.html")
      case File.read(pages_path) do
      {:ok, content} -> %{conv | status: 200, resp_body: content}
      {:error, :enoent} -> %{conv | status: 404, resp_body: "File not found"}
      {:error, reason} -> %{conv | status: 500, resp_body: "File error #{reason}"}
    end
  end



  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    form_path =
      @pages_path
      |> Path.join("form.html")
      case File.read(form_path) do
      {:ok, content} -> %{conv | status: 200, resp_body: content}
      {:error, :enoent} -> %{conv | status: 404, resp_body: "File not found"}
      {:error, reason} -> %{conv | status: 500, resp_body: "File error #{reason}"}
    end
  end

  def route(%Conv{method: "GET", path: "/bears?id=" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "DELETE"} = conv) do
    BearController.delete(conv, conv.params)
  end

  def route(%Conv{path: path} = conv) do
    %{conv | status: 404, resp_body: "#{path} não foi encontrado!"}
  end

  def route(%Conv{method: "GET", path: "/pages/" <> name} = conv) do
    @pages_path
    |> Path.join("#{name}.md")
    |> File.read
    |> handle_file(conv)
    |> markdown_to_html
  end

  def markdown_to_html(%Conv{status: 200} = conv) do
    %{ conv | resp_body: Earmark.as_html!(conv.resp_body) }
  end

  def markdown_to_html(%Conv{} = conv), do: conv

  def put_content_length(conv) do
    content = Map.put(conv.resp_headers, "Content-Length", String.length(conv.resp_body) )
    %{conv | resp_headers: content}
  end

  def format_response(conv) do
"""
HTTP/1.1 #{Conv.full_status(conv)}
Content-Type: #{conv.resp_headers["Content-Type"]}
Content-Length: #{conv.resp_headers["Content-Length"]}

#{conv.resp_body}
"""

end


end
