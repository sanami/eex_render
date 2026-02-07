defmodule DemoTest do
  use ExUnit.Case
  import Plug.Test

  test "GET /" do
    conn = conn(:get, "/") |> Demo.call(%{})
    assert conn.status == 200
    assert conn.resp_body =~ "home</h1>"
  end

  test "GET /page" do
    conn = conn(:get, "/page") |> Demo.call(%{})
    assert conn.status == 200
    assert conn.resp_body =~ "page</h1>"
  end

  test "POST /get-html" do
    conn = conn(:post, "/get-html") |> Demo.call(%{})
    assert conn.status == 200
    assert conn.resp_body =~ "<b>html</b>"
  end

  test "POST /get-json" do
    conn = conn(:post, "/get-json") |> Demo.call(%{})
    assert conn.status == 200
    assert JSON.decode!(conn.resp_body) == %{"a" => 1, "b" => "json"}
  end
end
