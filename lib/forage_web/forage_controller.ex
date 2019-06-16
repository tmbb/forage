defmodule ForageWeb.ForageController do
  @moduledoc """
  Helper functions for Plug controllers that use forage.
  """
  alias ForageWeb.Display

  @doc """
  Renders paginated data into a shape that the select widget expects.

  This function returns a map.
  The user must use the JSON encoder in the Phoenix application to generate a JSON response.

  It would be more succint to return JSON directly from this function,
  but Forage has no way of invoking the application's JSON encoder,
  so we leave that responsibility to the user.

  ## Example:

  TODO
  """
  def forage_select_data(paginated) do
    results =
      for entry <- paginated.entries do
        %{text: Display.display(entry), id: entry.id}
      end

    %{
      results: results,
      pagination: %{
        more: paginated.metadata.after != nil,
        after: paginated.metadata.after
      }
    }
  end

  @doc """
  Extracts the pagination data from the request `params`
  """
  def pagination_from_params(params) do
    Map.take(params, ["_pagination"])
  end
end
