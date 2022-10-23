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
  
  ## Examples:
  
  TODO
  """
  def forage_select_data(paginated) do
    results =
      for entry <- paginated.entries do
        %{text: Display.as_text(entry), id: Map.fetch!(entry, :id)}
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
  Renders paginated data into a shape that the select widget expects.
  Takes in either a field name (`text_field`) or a `converter` function
  to convert the entries into text.
  
  This function returns a map.
  The user must use the JSON encoder in the Phoenix application to generate a JSON response.
  
  It would be more succint to return JSON directly from this function,
  but Forage has no way of invoking the application's JSON encoder,
  so we leave that responsibility to the user.
  
  ## Examples:
  
  TODO
  """
  def forage_select_data(paginated, converter) when is_function(converter) do
    results =
      for entry <- paginated.entries do
        converter.(entry)
      end

    %{
      results: results,
      pagination: %{
        more: paginated.metadata.after != nil,
        after: paginated.metadata.after
      }
    }
  end

  def forage_select_data(paginated, text_field) when is_atom(text_field) do
    results =
      for entry <- paginated.entries do
        %{text: Map.fetch!(entry, text_field), id: Map.fetch!(entry, :id)}
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
  Renders paginated data into a shape that the select widget expects.
  Removes pagination data.
  
  This function returns a map.
  The user must use the JSON encoder in the Phoenix application to generate a JSON response.
  
  It would be more succint to return JSON directly from this function,
  but Forage has no way of invoking the application's JSON encoder,
  so we leave that responsibility to the user.
  
  ## Examples:
  
  TODO
  """
  def forage_select_data_without_pagination(entries) do
    results =
      for entry <- entries do
        %{text: Display.as_text(entry), id: entry.id}
      end

    %{results: results, pagination: %{}}
  end

  def forage_select_maps(maps) do
    %{results: maps, pagination: %{}}
  end

  @doc """
  Extracts the pagination data from the request `params`
  """
  def pagination_from_params(params) do
    Map.take(params, ["_pagination"])
  end
end
