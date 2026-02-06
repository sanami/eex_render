defmodule Helpers do
  def page_title(title) when is_list(title) do
    Enum.join(title ++ ["Demo"], " - ")
  end

  def page_title(nil), do: page_title([])
  def page_title(title), do: page_title([title])

  def header(page) do
    "<h1 class='text-capitalize'>#{page}</h1>"
  end
end
