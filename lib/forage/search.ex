defmodule Forage.Search do
  @moduledoc """
  Utilities to help with search
  """

  alias Ecto.Migration
  require ExUnit.Assertions, as: Assertions

  def define_forage_unaccent() do
    sql_unaccent_up = "CREATE EXTENSION IF NOT EXISTS unaccent;"
    sql_pg_trgm_up = "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
    sql_define_function_up = """
      CREATE OR REPLACE FUNCTION public.forage_unaccent(text)
        RETURNS text AS
      $func$
      SELECT public.unaccent('public.unaccent', $1)
      $func$

      LANGUAGE sql IMMUTABLE PARALLEL SAFE STRICT;
      """

    sql_unaccent_down = "DROP EXTENSION unaccent;"
    sql_pg_trgm_down = "DROP EXTENSION pg_trgm;"
    sql_define_function_down = "DROP FUNCTION public.forage_unaccent(text);"

    Migration.execute(sql_unaccent_up, sql_unaccent_down)
    Migration.execute(sql_pg_trgm_up, sql_pg_trgm_down)
    Migration.execute(sql_define_function_up, sql_define_function_down)
  end

  defp make_column_builder(columns) do
    coalesced = Enum.map(columns, fn name -> "coalesce(#{name}, '')" end)
    concatenated = Enum.intersperse(coalesced, " || ' ' || ")
    "(forage_unaccent(#{concatenated}))"
  end

  @doc """
  Adds a trigram index for the given `column` in the given `table`.

  This function is meant to be used in a migration file.

  ## Example

  *TODO*
  """
  def add_trigram_index(table, column) do
    # SQL statements to create and drop the index
    sql_index_up = """
    CREATE INDEX #{column}_idx ON #{table}
      USING GIN (#{column} gin_trgm_ops);
    """

    sql_index_down = """
    DROP INDEX #{column}_idx;
    """

    Migration.execute(sql_index_up, sql_index_down)
  end

  @doc """
  Adds a new column (named `column_name`) to the `table`.
  The new column will be a concatenation of the `columns`.
  The new column will be updated whenever any of the `columns` changes.

  This function is meant to be used in a migration file.

  To be able to use this functions you must have already defined the
  `forage_unaccent()` PostgreSQL function.
  The reason why we can't use `unaccent` directly is quite obscure;
  you can read more aboute it [here](#)

  ## Example

  *TODO*
  """
  def add_unnaccented_search_column(table, column_name, columns) do
    # Validate arguments:
    # - :table must be an atom
    Assertions.assert(is_atom(table))
    # - :columns must be a list of atoms
    Assertions.assert(is_list(columns))
    Assertions.assert(Enum.all?(columns, fn col -> is_atom(col) end))

    column_builder = make_column_builder(columns)

    # SQL statements to create and drop the column
    sql_column_up = """
    ALTER TABLE #{table}
      ADD COLUMN #{column_name} text
        GENERATED ALWAYS AS #{column_builder} STORED;
    """

    sql_column_down = """
    ALTER TABLE #{table}
      DROP COLUMN #{column_name};
    """

    Migration.execute(sql_column_up, sql_column_down)
  end

  def add_unaccented_search_column_and_index(table, search_column, columns) do
    add_unnaccented_search_column(table, search_column, columns)
    add_trigram_index(table, search_column)
  end

  @doc """
  Convert a search term into params that can be used in a forage plan.
  Search will be case-insensitive.

  This is implemented internally as an `ILIKE` operator.
  By default, the `ILIKE` operator doesn't ignore accents.
  If you want to ignore accents, you need to use `unaccented_search_params/2`
  and prepare a special column in your database (see [here](#)).

  If it makes sense for your application, you can implement
  better search yourself.
  """
  def naive_search_params(%{"_search" => term} = params, field) do
    field_string = to_string(field)
    map_with_new_filter = %{
      field_string => %{
        "op" => "contains",
        "val" => term
      }
    }

    replace_search_by_a_filter(params, map_with_new_filter)
  end

  @doc """
  Convert a search term into params that can be used in a forage plan.
  Search will be case-insensitive and will ignore accents.

  *Currently this function requires PostgreSQL*.

  This is implemented internally as an `ILIKE` operator.
  Thus function calls the special `forage_unaccent()` function,
  which you should have defined somehwere in your PostgreSQL database.

  If it makes sense for your application, you can implement
  better search yourself.
  """
  def unaccented_search_params(%{"_search" => term} = params, field) do
    field_string = to_string(field)
    map_with_new_filter = %{
      field_string => %{
        "op" => "contains_ignore_accents",
        "val" => term
      }
    }

    replace_search_by_a_filter(params, map_with_new_filter)
  end

  defp replace_search_by_a_filter(params, map_with_new_filter) do
    params
    |> Map.delete("_search")
    |> Map.update(
        "_filter",
        map_with_new_filter,
        fn filters -> Map.merge(filters, map_with_new_filter) end
      )
  end
end
