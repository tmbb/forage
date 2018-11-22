defmodule ForageWeb.ForageController do
  @moduledoc """
  Helper functions for controllers that use forage.
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
