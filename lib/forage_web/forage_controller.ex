defmodule ForageWeb.ForageController do
  @moduledoc """
  Helper functions for controllers that use forage.
  """

  @doc """
  Renders paginated data into a shape that the select widget expects.

  This function returns a map.
  The user must use the JSON encoder in the Phoenix application to generate a JSON response.

  It would be more succint to return JSON directly from this function,
  and better in case we ever want to depend on a client-side widget that expects something other than JSON,
  but Forage has no way of invoking the applications JSON encoder,
  so we leave that responsibility to the user.

  ## Example:

  TODO
  """
  def forage_select_data(paginated, struct_to_string) do
    results =
      for entry <- paginated.entries do
        %{text: struct_to_string.(entry), id: entry.id}
      end

    %{
      results: results,
      pagination: %{
        more: paginated.metadata.after != nil,
        after: paginated.metadata.after
      }
    }
  end
end
