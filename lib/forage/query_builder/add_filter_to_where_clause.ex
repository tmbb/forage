defmodule Forage.QueryBuilder.AddFilterToWhereClause do
  @moduledoc false
  require Ecto.Query, as: Query

  # Generic
  def add_filter_on_field(fragment, "equal_to", field_atom, value) do
    Query.dynamic([p], ^fragment and field(p, ^field_atom) == ^value)
  end

  def add_filter_on_field(fragment, "not_equal_to", field_atom, value) do
    Query.dynamic([p], ^fragment and field(p, ^field_atom) != ^value)
  end

  # Numeric
  def add_filter_on_field(fragment, "greater_than_or_equal_to", field_atom, value) do
    Query.dynamic([p], ^fragment and field(p, ^field_atom) >= ^value)
  end

  def add_filter_on_field(fragment, "less_than_or_equal_to", field_atom, value) do
    Query.dynamic([p], ^fragment and field(p, ^field_atom) <= ^value)
  end

  def add_filter_on_field(fragment, "greater_than", field_atom, value) do
    Query.dynamic([p], ^fragment and field(p, ^field_atom) > ^value)
  end

  def add_filter_on_field(fragment, "less_than", field_atom, value) do
    Query.dynamic([p], ^fragment and field(p, ^field_atom) < ^value)
  end

  # Text
  def add_filter_on_field(fragment, "contains", field_atom, value) do
    text = "%" <> escape_regex(value) <> "%"
    Query.dynamic([p], ^fragment and like(field(p, ^field_atom), ^text))
  end

  def add_filter_on_field(fragment, "postgresql:contains_ignore_accents", field_atom, value) do
    escaped = escape_regex(value)

    Query.dynamic(
      [p],
      like(
        field(p, ^field_atom),
        fragment("('%' || forage_unaccent(?) || '%')", ^escaped)
      ) and ^fragment
    )
  end

  def add_filter_on_field(fragment, "starts_with", field_atom, value) do
    text = escape_regex(value) <> "%"
    Query.dynamic([p], ^fragment and like(field(p, ^field_atom), ^text))
  end

  def add_filter_on_field(fragment, "ends_with", field_atom, value) do
    text = "%" <> escape_regex(value)
    Query.dynamic([p], ^fragment and like(field(p, ^field_atom), ^text))
  end

  # No operator is given: assume "equal_to"
  # TODO: should we raise an error?
  def add_filter_on_field(fragment, nil, field_atom, value) do
    text = value
    Query.dynamic([p], ^fragment and field(p, ^field_atom) == ^text)
  end

  # Generic
  def add_filter_on_assoc(fragment, "equal_to", assoc_atom, remote_field, value) do
    Query.dynamic(
      [{^assoc_atom, p}],
      ^fragment and field(p, ^remote_field) == ^value
    )
  end

  def add_filter_on_assoc(fragment, "not_equal_to", assoc_atom, remote_field, value) do
    Query.dynamic(
      [{^assoc_atom, p}],
      ^fragment and field(p, ^remote_field) != ^value
    )
  end

  # Numeric
  def add_filter_on_assoc(fragment, "greater_than_or_equal_to", assoc_atom, remote_field, value) do
    Query.dynamic(
      [{^assoc_atom, p}],
      ^fragment and field(p, ^remote_field) >= ^value
    )
  end

  def add_filter_on_assoc(fragment, "less_than_or_equal_to", assoc_atom, remote_field, value) do
    Query.dynamic(
      [{^assoc_atom, p}],
      ^fragment and field(p, ^remote_field) <= ^value
    )
  end

  def add_filter_on_assoc(fragment, "greater_than", assoc_atom, remote_field, value) do
    Query.dynamic(
      [{^assoc_atom, p}],
      ^fragment and field(p, ^remote_field) > ^value
    )
  end

  def add_filter_on_assoc(fragment, "less_than", assoc_atom, remote_field, value) do
    Query.dynamic(
      [{^assoc_atom, p}],
      ^fragment and field(p, ^remote_field) < ^value
    )
  end

  # Text
  def add_filter_on_assoc(fragment, "contains", assoc_atom, remote_field, value) do
    text = "%" <> escape_regex(value) <> "%"

    Query.dynamic(
      [{^assoc_atom, p}],
      ^fragment and like(field(p, ^remote_field), ^text)
    )
  end

  def add_filter_on_assoc(
        fragment,
        "postgresql:contains_ignore_accents",
        assoc_atom,
        remote_field,
        value
      ) do
    escaped = escape_regex(value)

    Query.dynamic(
      [{^assoc_atom, p}],
      like(
        field(p, ^remote_field),
        fragment("('%' || forage_unaccent(?) || '%')", ^escaped)
      ) and ^fragment
    )
  end

  def add_filter_on_assoc(fragment, "starts_with", assoc_atom, remote_field, value) do
    text = escape_regex(value) <> "%"

    Query.dynamic(
      [{^assoc_atom, p}],
      ^fragment and like(field(p, ^remote_field), ^text)
    )
  end

  def add_filter_on_assoc(fragment, "ends_with", assoc_atom, remote_field, value) do
    text = "%" <> escape_regex(value)

    Query.dynamic(
      [{^assoc_atom, p}],
      ^fragment and like(field(p, ^remote_field), ^text)
    )
  end

  # No operator is given: assume "equal_to"
  # TODO: should we raise an error?
  def add_filter_on_assoc(fragment, nil, assoc_atom, remote_field, value) do
    text = value

    Query.dynamic(
      [{^assoc_atom, p}],
      ^fragment and field(p, ^remote_field) == ^text
    )
  end

  @doc false
  def escape_regex(regex_string) do
    regex_string
    |> String.replace("_", "\\_")
    |> String.replace("%", "\\%")
  end
end
