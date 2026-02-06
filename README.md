# EExRender

A view engine for rendering EEx templates.
Complete demo application is in "demo" [subfolder](https://github.com/sanami/eex_render/tree/master/demo) 

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `eex_render` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:eex_render, "~> 0.1"},
  ]
end
```

## Usage

```elixir
defmodule Demo do
  use Plug.Router

  use EExRender,
    templates: ["lib/template/"],
    layout: "layout",
    helpers: [Helpers]

  get "/" do
    conn
    |> render("home")
  end
end
```

- All files `*.html.eex` in `lib/template` will be precompiled to EEx templates.
- `layout.html.eex` is set as default layout, therefore it must exists and contain `<%= @main_content %>`  
- All functions in `Helpers` module will be available in templates

This way `render("home")` will render `home.html.eex` inside `layout.html.eex` and send as HTML response

Other usages:
- `render(conn, html: "<b>html</b>")` send HTML fragment (without layout)
- `render(conn, json: %{a: 1, b: "json"})` send JSON
- `render(conn, text: "OK")` send text/plain
- `render(conn, text: "Not Found", status: 404, content_type: "vnd/error)` custom status/content_type
