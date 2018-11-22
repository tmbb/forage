defmodule ForageWeb.ForageView do
  @moduledoc """
  Helper functions for veiws that feature forage filters, pagination buttons or sort links.
  """
  import Phoenix.HTML, only: [sigil_e: 2]
  import Phoenix.HTML.Link, only: [link: 2]
  import Phoenix.HTML.Form, only: [input_value: 2, form_for: 4, select: 4]
  alias Phoenix.HTML.FormData
  alias ForageWeb.Naming

  defmacro __using__(options) do
    routes_module =
      case Keyword.fetch(options, :routes_module) do
        {:ok, module} -> module
        :error -> raise ArgumentError, "Requires a `:routes_module`."
      end

    prefix =
      case Keyword.fetch(options, :prefix) do
        {:ok, val} -> val
        :error -> raise ArgumentError, "Requires a `:prefix`."
      end

    resource_path_fun_name = String.to_atom("#{prefix}_path")
    pagination_widget_fun_name = String.to_atom("#{prefix}_pagination_widget")
    sort_link_fun_name = String.to_atom("#{prefix}_sort_link")
    search_form_for_fun_name = String.to_atom("#{prefix}_search_form_for")

    quote do
      import ForageWeb.ForageView

      def unquote(search_form_for_fun_name)(conn, options \\ [], fun) do
        action = unquote(routes_module).unquote(resource_path_fun_name)(conn, :index)

        forage_search_form_for(
          conn,
          action,
          options,
          fun
        )
      end

      def unquote(sort_link_fun_name)(conn, field, content, options \\ []) do
        forage_sort_link(
          conn,
          unquote(routes_module),
          unquote(resource_path_fun_name),
          field,
          content,
          options
        )
      end

      def unquote(pagination_widget_fun_name)(conn, resource, options \\ []) do
        forage_pagination_widget(
          conn,
          resource,
          unquote(routes_module),
          unquote(resource_path_fun_name),
          options
        )
      end
    end
  end

  def forage_select(form, field, opts) do
    # Params
    path = Keyword.fetch!(opts, :path)
    display = Keyword.fetch!(opts, :display)
    remote_field = Keyword.fetch!(opts, :remote_field)
    # Derived values
    field_value = Map.get(form.data, field)

    ~e"""
    <select
      name="<%= form.name %>[<%= field %>_id]"
      class="form-control"
      data-forage-select2-widget="true"
      data-url="<%= path %>"
      data-field="<%= remote_field %>">
        <option value="<%= field_value && field_value.id %>"><%= display.(field_value) %></option>
    </select>
    """
  end

  def forage_select_filter(form, field, opts) do
    # Params
    path = Keyword.fetch!(opts, :path)
    display = Keyword.fetch!(opts, :display)
    remote_field = Keyword.fetch!(opts, :remote_field)
    # Derived values
    IO.inspect({form.data, field})
    field_value = Map.get(form.data, field)

    ~e"""
    <select
      name="_search[<%= field %>_id][val]"
      class="form-control"
      data-forage-select2-widget="true"
      data-url="<%= path %>"
      data-field="<%= remote_field %>">
        <option value="<%= field_value && field_value.id %>"><%= display.(field_value) %></option>
    </select>
    <input type="hidden" name="_search[<%= field %>_id][op]" value="equal_to"/>
    """
  end

  @text_operators [
    {"Contains", "contains"},
    {"Equal to", "equal_to"},
    {"Starts with", "starts_with"},
    {"Ends with", "ends_with"}
  ]

  @number_operators [
    {"Equal to", "equal_to"},
    {"Greater than", "greater_than"},
    {"Less than", "less_than"},
    {"Greater than or equal to", "greater_than_or_equal_to"},
    {"Less than or equal to", "less_than_or_equal_to"}
  ]

  @operator_class "col-sm-3"
  @value_class "col-sm-9"

  defp name_to_search_id(name) do
    ["_search", to_string(name)]
  end

  defp sort_direction(conn, field) do
    direction_string = get_in(conn.params, ["_sort", to_string(field), "direction"])

    case direction_string do
      "asc" -> :asc
      "desc" -> :desc
      nil -> nil
    end
  end

  defp sort_by(conn, field, direction) do
    conn.params
    # Remove the old pagination data, which is useless now
    |> Map.delete("_pagination")
    |> Map.put("_sort", %{field => %{"direction" => direction}})
  end

  def forage_sort_link(conn, mod, fun, field, content, options \\ []) do
    icon_down = Keyword.get(options, :icon_down, " ↓")
    icon_up = Keyword.get(options, :icon_up, " ↑")

    {link_content, new_conn_params} =
      case sort_direction(conn, field) do
        :asc ->
          {[content, " ", icon_down], sort_by(conn, field, "desc")}

        :desc ->
          {[content, " ", icon_up], sort_by(conn, field, "asc")}

        nil ->
          {content, sort_by(conn, field, "desc")}
      end

    destination = apply(mod, fun, [conn, :index, new_conn_params])
    link(link_content, to: destination)
  end

  def forage_pagination_link_previous(conn, resource, mod, fun, contents) do
    if resource.metadata.before do
      before_params = Map.put(conn.params, :_pagination, %{before: resource.metadata.before})
      destination = apply(mod, fun, [conn, :index, before_params])
      ~e'<li><a href="<%= destination %>"><%= contents %></a></li>'
    else
      ~e''
    end
  end

  def forage_pagination_link_next(conn, resource, mod, fun, contents) do
    if resource.metadata.after do
      after_params = Map.put(conn.params, :_pagination, %{after: resource.metadata.after})
      destination = apply(mod, fun, [conn, :index, after_params])
      ~e'<li><a href="<%= destination %>"><%= contents %></a></li>'
    else
      ~e''
    end
  end

  def forage_pagination_widget(conn, resource, mod, fun, options) do
    previous_text = Keyword.get(options, :previous, "« Previous")
    next_text = Keyword.get(options, :next, "Next »")
    classes = Keyword.get(options, :classes, "pagination-sm no-margin pull-right")

    ~e"""
    <ul class="pagination <%= classes %>">
      <%= forage_pagination_link_previous conn, resource, mod, fun, previous_text %>
      <%= forage_pagination_link_next conn, resource, mod, fun, next_text %>
    </ul>
    """
  end

  @doc """
  Form group for horizontal forms.
  """
  def forage_horizontal_form_group(name, opts \\ [], do: content) do
    label = Keyword.get(opts, :label, [Naming.humanize(name), ":"])
    input_id = Keyword.get(opts, :id, name_to_search_id(name))
    {label_class, inputs_class} = Keyword.get(opts, :classes, {"col-sm-2", "col-sm-10"})

    ~e"""
    <div class="form-group">
      <label for="<%= input_id %>" class="control-label <%= label_class %>"><%= label %></label>
      <div class="<%= inputs_class %>">
        <%= content %>
      </div>
    </div>
    """
  end

  def forage_active_filters?(%{params: %{"_search" => _}} = _conn), do: true

  def forage_active_filters?(_conn), do: false

  @spec forage_search_form_for(
          FormData.t(),
          String.t(),
          Keyword.t(),
          (FormData.t() -> Phoenix.HTML.unsafe())
        ) :: Phoenix.HTML.safe()
  def forage_search_form_for(conn, action, options \\ [], fun) do
    new_options =
      options
      |> Keyword.put_new(:as, :_search)
      |> Keyword.put_new(:method, "get")
      |> Keyword.put_new(:class, "form-horizontal")

    form_for(conn, action, new_options, fun)
  end

  @doc false
  def input_value_and_name(form, {name, index} = _field_spec) do
    # A custom implementation of `Phoenix.HTML.Form.input_value/2`
    # to handle cases where there are fields with the same name but
    # different indices
    indexed_map = input_value(form, name)
    stringified_index = to_string(index)
    value = Map.get(indexed_map, stringified_index)
    name_for_form = ~e'<%= name %>[<%= index %>]'
    {value, name_for_form}
  end

  def input_value_and_name(form, name) do
    # Use the default implementation (same as in `Phoenix.HTML.Form`)
    {input_value(form, name), name}
  end

  defp generic_forage_filter(type, form, field_spec, default_operators, opts) do
    operators = Keyword.get(opts, :operators, default_operators)
    # Extract the field name from the id if necessary
    {field_values, name} = input_value_and_name(form, field_spec)

    {operator, value} =
      case field_values do
        nil ->
          [{_operator_name, operator_value} | _rest] = operators
          {operator_value, nil}

        %{"op" => operator, "val" => value} ->
          {operator, value}
      end

    {operator_class, value_class} = Keyword.get(opts, :classes, {@operator_class, @value_class})

    ~e"""
    <div class="row">
      <div class="<%= operator_class %>">
        <select name="_search[<%= name %>][op]" class="form-control">
          <%= for {op_name, op_value} <- operators do %>
            <option value="<%= op_value %>"<%= if op_value == operator do %> selected="true"<% end %>><%= op_name %></option>
          <% end %>
        </select>
      </div>
      <div class="<%= value_class %>">
        <input type="<%= type %>" name="_search[<%= name %>][val]" class="form-control" value="<%= value %>"></input>
      </div>
    </div>
    """
  end

  def forage_text_filter(form, name, opts \\ []) do
    generic_forage_filter("text", form, name, @text_operators, opts)
  end

  def forage_numeric_filter(form, name, opts \\ []) do
    generic_forage_filter("number", form, name, @number_operators, opts)
  end

  def forage_date_filter(form, name, opts \\ []) do
    generic_forage_filter("date", form, name, @number_operators, opts)
  end

  def forage_time_filter(form, name, opts \\ []) do
    generic_forage_filter("time", form, name, @number_operators, opts)
  end
end