# EExRender

A view engine for rendering EEx templates.
Complete demo application is in "demo" [subfolder](https://github.com/sanami/eex_render/tree/master/demo) 

## Installation

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
    template_ext: ".html.eex",    # if not set default is ".html.eex"
    layout: "layout",             # lib/template/layout.html.eex
    helpers: [Helpers]            # default is []

  get "/" do
    conn
    |> assign(:key1, "val1")      # accessible in template as `@key1` or `@assigns[:key]`
    |> render("home")             # lib/template/home.html.eex
  end
end
```

- All `**/*.html.eex` files in `lib/template` will be precompiled to EEx template functions.
- Subfolders stay in template name, e.g. "partial/menu"
- `layout.html.eex` is set as default layout, therefore it must exists and contain `<%= @main_content %>`
- All functions in `Helpers` module will be available in templates
- Custom template extension can be used, e.g. `template_ext: ".eex"`

This way `render(conn, "home")` will render `home.html.eex` inside `layout.html.eex` and send as HTML response

### Other usages

- `render(conn, html: "<b>html</b>")` send HTML fragment (without layout)
- `render(conn, json: %{a: 1, b: "json"})` send JSON
- `render(conn, text: "OK")` send text/plain
- `render(conn, text: "Not Found", status: 404, content_type: "vnd/error")` custom status/content_type
- `render(conn, "full_error_page", layout: false, status: 404)` render `full_error_page.html.eex` without layout
- `render(conn, "error_message", layout: "error_page", status: 404)` render `error_message.html.eex` with custom layout `error_page.html.eex`

### In templates

- `render("partial/menu", key1: 11, key2: 22)` render `partial/menu.html.eex` inside current template
- given locals available as `@key1` and `@key2`
- all locals are in `@assigns`, presence can be checked with `@assigns[:key1]`
- all given helper modules are imported - their functions can be called directly
