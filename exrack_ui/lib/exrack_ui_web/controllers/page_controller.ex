defmodule ExRackUIWeb.PageController do
  use ExRackUIWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
