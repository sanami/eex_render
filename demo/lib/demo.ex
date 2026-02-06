defmodule Demo do
  use Plug.Router

  plug Plug.Static, at: "/", from: "priv/assets"
  plug Plug.Logger
  plug :match
  plug Plug.Parsers, parsers: [:urlencoded]
  plug :dispatch

  use EExRender,
    templates: ["lib/template/"],
    layout: "layout",
    helpers: [Helpers]

  get "/" do
    conn
    |> assign(:page_title, "Home")
    |> assign(:current, :home)
    |> render("home")
  end

  get "/page" do
    conn
    |> assign(:page_title, "Page")
    |> assign(:current, :page)
    |> render("page")
  end

  post "/get-html" do
    conn
    |> render(html: "<b>html</b>")
  end

  post "/get-json" do
    conn
    |> render(json: %{a: 1, b: "json"})
  end
end
