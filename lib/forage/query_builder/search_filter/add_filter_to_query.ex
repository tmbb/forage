defmodule Forage.QueryBuilder.SearchFilter.AddFilterToQuery do
  import Ecto.Query, only: [dynamic: 2]

  def filter_adder_clauses(filter_adder, n, i) do
    underscore_list = List.duplicate(quote(do: _), n - 1)
    var = Macro.var(:x, __MODULE__)
    variables_list = List.insert_at(underscore_list, i, var)

    quote do
      # There are two cases we must handle:
      #   1. The previous fragment is a literal `true` atom
      #   2. The previous fragment is already a non-trivial query
      #
      # Handling these two cases might be a little unnecessary,
      # but it produces cleaner queries
      #
      # -------------------------
      # There is a prior fragment
      # -------------------------
      # Generic
      defp unquote(filter_adder)(unquote(n), unquote(i), true, "equal_to", field_atom, value) do
        dynamic(unquote(variables_list), field(unquote(var), ^field_atom) == ^value)
      end

      defp unquote(filter_adder)(unquote(n), unquote(i), true, "not_equal_to", field_atom, value) do
        dynamic(unquote(variables_list), field(unquote(var), ^field_atom) != ^value)
      end

      # Numeric
      defp unquote(filter_adder)(unquote(n), unquote(i), true, "greater_than_or_equal_to", field_atom, value) do
        dynamic(unquote(variables_list), field(unquote(var), ^field_atom) >= ^value)
      end

      defp unquote(filter_adder)(unquote(n), unquote(i), true, "less_than_or_equal_to", field_atom, value) do
        dynamic(unquote(variables_list), field(unquote(var), ^field_atom) <= ^value)
      end

      defp unquote(filter_adder)(unquote(n), unquote(i), true, "greater_than", field_atom, value) do
        dynamic(unquote(variables_list), field(unquote(var), ^field_atom) > ^value)
      end

      defp unquote(filter_adder)(unquote(n), unquote(i), true, "less_than", field_atom, value) do
        dynamic(unquote(variables_list), field(unquote(var), ^field_atom) < ^value)
      end

      # Text
      defp unquote(filter_adder)(unquote(n), unquote(i), true, "contains", field_atom, value) do
        text = "%" <> value <> "%"
        dynamic(unquote(variables_list), ilike(field(unquote(var), ^field_atom), ^text))
      end

      defp unquote(filter_adder)(unquote(n), unquote(i), true, "starts_with", field_atom, value) do
        text = value <> "%"
        dynamic(unquote(variables_list), ilike(field(unquote(var), ^field_atom), ^text))
      end

      defp unquote(filter_adder)(unquote(n), unquote(i), true, "ends_with", field_atom, value) do
        text = "%" <> value
        dynamic(unquote(variables_list), ilike(field(unquote(var), ^field_atom), ^text))
      end

      # No operator is given: assume "equal_to"
      # TODO: should we raise an error?
      defp unquote(filter_adder)(unquote(n), unquote(i), true, nil, field_atom, value) do
        text = value
        dynamic(unquote(variables_list), field(unquote(var), ^field_atom) == ^text)
      end

      # --------------------------
      # There is no prior fragment
      # --------------------------
      # Generic
      defp unquote(filter_adder)(unquote(n), unquote(i), fragment, "equal_to", field_atom, value) do
        dynamic(unquote(variables_list), field(unquote(var), ^field_atom) == ^value and ^fragment)
      end

      defp unquote(filter_adder)(unquote(n), unquote(i), fragment, "not_equal_to", field_atom, value) do
        dynamic(unquote(variables_list), field(unquote(var), ^field_atom) != ^value and ^fragment)
      end

      # Numeric
      defp unquote(filter_adder)(unquote(n), unquote(i), fragment, "greater_than_or_equal_to", field_atom, value) do
        dynamic(unquote(variables_list), field(unquote(var), ^field_atom) >= ^value and ^fragment)
      end

      defp unquote(filter_adder)(unquote(n), unquote(i), fragment, "less_than_or_equal_to", field_atom, value) do
        dynamic(unquote(variables_list), field(unquote(var), ^field_atom) <= ^value and ^fragment)
      end

      defp unquote(filter_adder)(unquote(n), unquote(i), fragment, "greater_than", field_atom, value) do
        dynamic(unquote(variables_list), field(unquote(var), ^field_atom) > ^value and ^fragment)
      end

      defp unquote(filter_adder)(unquote(n), unquote(i), fragment, "less_than", field_atom, value) do
        dynamic(unquote(variables_list), field(unquote(var), ^field_atom) < ^value and ^fragment)
      end

      # Text
      defp unquote(filter_adder)(unquote(n), unquote(i), fragment, "contains", field_atom, value) do
        text = "%" <> value <> "%"
        dynamic(unquote(variables_list), ilike(field(unquote(var), ^field_atom), ^text) and ^fragment)
      end

      defp unquote(filter_adder)(unquote(n), unquote(i), fragment, "starts_with", field_atom, value) do
        text = value <> "%"
        dynamic(unquote(variables_list), ilike(field(unquote(var), ^field_atom), ^text) and ^fragment)
      end

      defp unquote(filter_adder)(unquote(n), unquote(i), fragment, "ends_with", field_atom, value) do
        text = "%" <> value
        dynamic(unquote(variables_list), ilike(field(unquote(var), ^field_atom), ^text) and ^fragment)
      end

      # No operator is given: assume "equal_to"
      # TODO: should we raise an error?
      defp unquote(filter_adder)(unquote(n), unquote(i), fragment, nil, field_atom, value) do
        text = value
        dynamic(unquote(variables_list), field(unquote(var), ^field_atom) == ^text and ^fragment)
      end
    end
  end

  @doc """
  Defines a function that adds fields to a pre-existing Ecto query.

  The function is named `filter_adder` (must be an atom) and will support
  up to `n_max` variables in the query.
  """
  defmacro define_filter_adder(filter_adder, n_max) do
    clauses =
      for n <- 1..n_max do
        for i <- 0..(n - 1) do
          filter_adder_clauses(filter_adder, n, i)
        end
      end

    quote do
      unquote_splicing(clauses)
    end
  end
end

