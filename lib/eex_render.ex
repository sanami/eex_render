defmodule EExRender do
  @view_schema [
    templates: [
      type: {:or, [:string, {:list, :string}]},
      required: true
    ],
    template_ext: [
      type: :string,
      default: ".html.eex",
      required: false
    ],
    layout: [
      type: {:or, [:atom, :string]},
      required: true
    ],
    helpers: [
      type: {:or, [:atom, {:list, :atom}]},
      default: [],
      required: false
    ]
  ]

  @spec init_options(keyword(), Macro.t()) :: keyword()
  def init_options(opts, caller) do
    opts
    |> Keyword.update(:helpers, [], fn list ->
      Enum.map(List.wrap(list), &Macro.expand(&1, caller))
    end)
    |> NimbleOptions.validate!(@view_schema)
    |> Keyword.update!(:templates, &List.wrap/1)
    |> Keyword.update!(:layout, fn
      t when is_binary(t) -> String.to_atom(t)
      t -> t
    end)
  end

  defmacro __using__(opts) do
    opts = init_options(opts, __CALLER__)

    quote do
      defmodule Template do
        require EEx

        unquote_splicing(for helper_mod <- opts[:helpers] do
          quote do: import(unquote(helper_mod))
        end)

        @spec render(binary() | atom(), keyword()) :: binary()
        def render(template, assigns) when is_binary(template), do: render(String.to_atom(template), assigns)

        def render(template, assigns) when is_atom(template) do
          assigns = [{:assigns, assigns} | assigns]
          apply(__MODULE__, template, [assigns])
        end

        Enum.each(unquote(opts[:templates]), fn folder ->
          Path.join(folder, "**/*#{unquote(opts[:template_ext])}")
          |> Path.wildcard
          |> Enum.each(fn file ->
            @external_resource file

            name =
              file
              |> Path.relative_to(folder)
              |> String.trim_trailing(unquote(opts[:template_ext]))
              |> String.to_atom

            EEx.function_from_file(:def, name, file, [:assigns], engine: EEx.SmartEngine)
          end)
        end)
      end

      @render_schema [
        html: [type: :any, required: false],
        json: [type: :any, required: false],
        text: [type: :any, required: false],
        status: [
          type: :non_neg_integer,
          required: false,
          default: 200
        ],
        content_type: [
          type: :string,
          required: false
        ],
      ]

      @spec render(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
      def render(conn, render_opts) when is_list(render_opts) do
        render_opts = NimbleOptions.validate!(render_opts, @render_schema)

        # Ensure exactly one format is provided
        provided_formats = Enum.count([:html, :json, :text], &(Keyword.has_key?(render_opts, &1)))
        if provided_formats != 1 do
          raise ArgumentError, "render/2 expects exactly one of :html, :json, or :text"
        end

        # Identify format and set default content type
        {type, default_ct} =
          cond do
            render_opts[:html] -> {:html, "text/html"}
            render_opts[:json] -> {:json, "application/json"}
            render_opts[:text] -> {:text, "text/plain"}
          end

        # Process the body based on type
        body =
          case {type, render_opts[type]} do
            {:json, data} when not is_binary(data) -> JSON.encode!(data)
            {_type, data} -> to_string(data)
          end

        conn
        |> put_resp_content_type(render_opts[:content_type] || default_ct)
        |> send_resp(render_opts[:status], body)
      end

      @render_html_schema [
        layout: [
          type: {:or, [:atom, :string]},
          required: false,
          default: unquote(opts[:layout])
        ],
        status: [
          type: :non_neg_integer,
          required: false,
          default: 200
        ],
        content_type: [
          type: :string,
          required: false
        ],
      ]

      @spec render(Plug.Conn.t(), binary() | atom(), keyword()) :: Plug.Conn.t()
      def render(conn, template, render_opts \\ [])

      def render(conn, template, render_opts) when is_binary(template), do: render(conn, String.to_atom(template), render_opts)

      def render(conn, template, render_opts) when is_atom(template) and is_list(render_opts) do
        render_opts =
          render_opts
          |> NimbleOptions.validate!(@render_html_schema)
          |> Keyword.update(:layout, nil, fn
            t when is_binary(t) -> String.to_atom(t)
            t -> t
          end)

        assigns =  Map.put(conn.assigns, :assigns, conn.assigns)
        main_content = apply(Template, template, [assigns])

        html =
          if render_opts[:layout] do
            assigns = Map.put(assigns, :main_content, main_content)
            apply(Template, unquote(opts[:layout]), [assigns])
          else
            main_content
          end

        render_opts =
          render_opts
          |> Keyword.delete(:layout)
          |> Keyword.put(:html, html)

        render(conn, render_opts)
      end
    end
  end
end
