defmodule EExRenderTest do
  defmodule Helpers do
    def helper(str) do
      "#{str}!"
    end
  end

  defmodule Sample do
    use Plug.Router

    use EExRender,
      templates: "test/template/",
      template_ext: ".eex",
      layout: "layout",
      helpers: Helpers

    plug :match
    plug :dispatch

    get "/page" do
      conn
      |> assign(:key1, "page_assign")
      |> render("page")
    end

    get "/page/no_layout" do
      conn
      |> render("page", layout: false)
    end

    get "/page/custom_layout" do
      conn
      |> render("page", layout: "layout2")
    end

    get "/status" do
      conn
      |> render(text: "OK", status: 201)
    end

    get "/text" do
      render(conn, text: :a)
    end

    get "/html" do
      render(conn, html: :a)
    end

    get "/json" do
      render(conn, json: %{a: 1})
    end
  end

  use ExUnit.Case
  import Plug.Test
  import Plug.Conn

  describe "render" do
    test "layout -> page -> partial" do
      conn = call(Sample, conn(:get, "/page"))
      assert conn.status == 200
      assert content_type(conn) =~ "text/html"

      assert conn.resp_body =~ "[layout]"

      assert conn.resp_body =~ "[page]"
      assert conn.resp_body =~ "page_assign"
      assert conn.resp_body =~ "page_helper!"

      assert conn.resp_body =~ "[partial]"
      assert conn.resp_body =~ "partial_assign"
      assert conn.resp_body =~ "partial_helper!"
    end

    test "no layout" do
      conn = call(Sample, conn(:get, "/page/no_layout"))
      refute conn.resp_body =~ "[layout]"
      assert conn.resp_body =~ "[page]"
    end

    test "custom layout" do
      conn = call(Sample, conn(:get, "/page/custom_layout"))
      assert conn.resp_body =~ "[layout2]"
      assert conn.resp_body =~ "[page]"
    end

    test "status" do
      conn = call(Sample, conn(:get, "/status"))
      assert conn.status == 201
    end

    test "text" do
      conn = call(Sample, conn(:get, "/text"))
      assert content_type(conn) =~ "text/plain"
      assert conn.resp_body == "a"
    end

    test "html" do
      conn = call(Sample, conn(:get, "/html"))
      assert content_type(conn) =~ "text/html"
      assert conn.resp_body == "a"
    end

    test "json" do
      conn = call(Sample, conn(:get, "/json"))
      assert content_type(conn) =~ "application/json"
      assert conn.resp_body == "{\"a\":1}"
    end
  end

  defp call(mod, conn) do
    mod.call(conn, [])
  end

  defp content_type(conn) do
    [content_type] = get_resp_header(conn, "content-type")
    content_type
  end
end
