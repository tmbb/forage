defmodule ForageWeb.ForageView do
  @moduledoc """
  Helper functions for views that feature forage filters, pagination buttons or sort links.
  """
  import Phoenix.HTML, only: [sigil_e: 2]
  import Phoenix.HTML.Link, only: [link: 2]
  import Phoenix.HTML.Form, only: [input_value: 2, form_for: 4]
  require Logger
  alias Phoenix.HTML.{Form, FormData}
  alias ForageWeb.Display
  alias Ecto.Association.NotLoaded

  @type form_data :: Phoenix.HTML.FormData.t()
  @type safe_html :: Phoenix.HTML.Safe.t()
  @type form_field :: atom()
  @type options :: Keyword.t()

  @doc """
  Specialized version of `ForageWeb.ForageView.forage_form_group/6`
  that's meant to use the application's error helpers module for internationalization.

  This callback is automatically implemented by `use ForageWeb.ForageView, ...`

  ## Examples

  TODO
  """
  @callback forage_form_group(
    form_data(),
    form_field(),
    String.t(),
    options(),
    (form_data, form_field(), options() -> safe_html())
  ) :: safe_html()

  @doc """
  Specialized version of `ForageWeb.ForageView.forage_horizontal_form_group/6`.
  that's meant to use the application's error helpers module for internationalization.

  This callback is automatically implemented by `use ForageWeb.ForageView, ...`

  ## Examples

  TODO
  """
  @callback forage_horizontal_form_group(
    form_data(),
    form_field(),
    String.t(),
    options(),
    (form_data, form_field(), options() -> safe_html())
  ) :: safe_html()

  @doc """
  Specialized version of `ForageWeb.ForageView.forage_form_check/6`.
  that's meant to use the application's error helpers module for internationalization.

  This callback is automatically implemented by `use ForageWeb.ForageView, ...`

  ## Examples

  TODO
  """
  @callback forage_form_check(
    form_data(),
    form_field(),
    String.t(),
    options(),
    (form_data, form_field(), options() -> safe_html())
  ) :: safe_html()

  @doc """
  Specialized version of `ForageWeb.ForageView.forage_inline_form_check/6`.
  that's meant to use the application's error helpers module for internationalization.

  This callback is automatically implemented by `use ForageWeb.ForageView, ...`

  ## Examples

  TODO
  """
  @callback forage_inline_form_check(
    form_data(),
    form_field(),
    String.t(),
    options(),
    (form_data, form_field(), options() -> safe_html())
  ) :: safe_html()

  @doc """
  Imports functions from `ForageWeb.ForageView` and defines a number of functions
  specialized for the given resource.

  TODO: complete this.
  """
  defmacro __using__(options) do
    caller_module = __CALLER__.module

    routes_module =
      case Keyword.fetch(options, :routes_module) do
        # Atoms are represented as themselves in the AST
        {:ok, module} ->
          module

        :error ->
          raise ArgumentError, "Requires a `:routes_module`."
      end

    prefix =
      case Keyword.fetch(options, :prefix) do
        {:ok, val} when is_atom(val) -> val
        :error -> raise ArgumentError, "Requires a `:prefix`."
      end

    maybe_internationalized_forage_widgets =
      case Keyword.fetch(options, :error_helpers_module) do
        :error ->
          Logger.warn(fn -> """
            No `:error_helpers_module` was specified in the `use #{caller_module}, ...` call.
            This way, Forage can't generate the specialized helpers.
            If you don't want to generate the helpers, explicitly pass `nil` as an argument:
            `use #{caller_module}, error_helpers_module: nil`
            """
          end)

          nil

        # The user has explicitly given `nil` as the value for the `:error_helpers_module` option.
        # Everything's ok, don't log a warning.
        {:ok, nil} ->
          nil

        {:ok, error_helpers_module} ->
          internationalized_forage_widgets(error_helpers_module)
      end

    prefixed_widgets = prefixed_forage_widgets(routes_module, prefix)

    quote do
      import ForageWeb.ForageView

      unquote(maybe_internationalized_forage_widgets)
      unquote(prefixed_widgets)
    end
  end

  defp prefixed_forage_widgets(routes_module, prefix) do
    resource_path_fun_name = String.to_atom("#{prefix}_path")
    pagination_widget_fun_name = String.to_atom("#{prefix}_pagination_widget")
    sort_link_fun_name = String.to_atom("#{prefix}_sort_link")
    filter_form_for_fun_name = String.to_atom("#{prefix}_filter_form_for")

    quote do
      def unquote(filter_form_for_fun_name)(conn, options \\ [], fun) do
        action = unquote(routes_module).unquote(resource_path_fun_name)(conn, :index)

        forage_filter_form_for(
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

  defp internationalized_forage_widgets(error_helpers) do
    forage_form_group_docs =
      internationalization_aware_forage_widgets(error_helpers, :forage_form_group, 5)

    forage_horizontal_form_group_docs =
        internationalization_aware_forage_widgets(error_helpers, :forage_horizontal_form_group, 5)

    forage_form_check_docs =
      internationalization_aware_forage_widgets(error_helpers, :forage_form_check, 5)

    forage_inline_form_check_docs =
      internationalization_aware_forage_widgets(error_helpers, :forage_inline_form_check, 5)

    quote do
      @doc unquote(forage_form_group_docs)
      def forage_form_group(form_data, field, label, opts, input_fun) do
        ForageWeb.ForageView.forage_form_group(
          form_data,
          field,
          label,
          unquote(error_helpers),
          opts,
          input_fun
        )
      end

      @doc unquote(forage_horizontal_form_group_docs)
      def forage_horizontal_form_group(form_data, field, label, opts, input_fun) when is_list(opts) do
        ForageWeb.ForageView.forage_horizontal_form_group(
          form_data,
          field,
          label,
          unquote(error_helpers),
          opts,
          input_fun
        )
      end

      @doc unquote(forage_form_check_docs)
      def forage_form_check(form_data, field, label, opts, input_fun) do
        ForageWeb.ForageView.forage_form_check(
          form_data,
          field,
          label,
          unquote(error_helpers),
          opts,
          input_fun
        )
      end

      @doc unquote(forage_inline_form_check_docs)
      def forage_inline_form_check(form_data, field, label, opts, input_fun) do
        ForageWeb.ForageView.forage_inline_form_check(
          form_data,
          field,
          label,
          unquote(error_helpers),
          input_fun
        )
      end
    end
  end

  defp internationalization_aware_forage_widgets(error_helpers, name, arity) do
    """
    Specialized version of `ForageWeb.ForageView.#{name}/#{arity}`
    that uses the application's error helpers module (`#{inspect(error_helpers)}`)
    for internationalization.
    """
  end

  def forage_error_tag(form, field, error_helpers) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      ~e"""
      <div class="invalid-feedback">
        <%= error_helpers.translate_error(error) %>
      </div>
      """
    end)
  end

  def forage_horizontal_error_tag(form, field, error_helpers, class) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      ~e"""
      <div class="invalid-feedback <%= class %>">
        <%= error_helpers.translate_error(error) %>
      </div>
      """
    end)
  end

  @doc """
  TODO
  """
  def forage_form_check(form, field, label, error_helpers, opts, input_fun) do
    forage_generic_form_check(form, field, label, error_helpers, opts, false, input_fun)
  end

  @doc """
  TODO
  """
  def forage_inline_form_check(form, field, label, error_helpers, opts, input_fun) do
    forage_generic_form_check(form, field, label, error_helpers, opts, true, input_fun)
  end

  defp forage_generic_form_check(form, field, label, error_helpers, opts, inline?, input_fun) do
    outer_div_class = (inline? && "form-check form-check-inline") || "form-check"

    ~e"""
    <div class="<%= outer_div_class %>">
      <%= input_fun.(form, field, opts) %>
      <%= Form.label form, field, label, class: "form-check-label" %>
      <%= forage_error_tag(form, field, error_helpers) %>
    </div>
    """
  end

  def forage_row(widgets) do
    [
      ~e[<div class="row">],
      Enum.map(widgets, fn w -> [~e[<div class="col">], w, ~e[</div>]] end),
      ~e[</div>]
    ]
  end

  @doc """
  Creates a fragment that can be reused in the same template.

  It's meant to be used in an EEx template, which has some synctatic
  restrictions that make it hard to set a variable to a an EEx fragment.

  ## Example

      <%= fragment widget do %>
        <div class="my-widget">
          Add an EEx fragment here.
          Can contain <%= @dynamic %> fragments.
        </div>
      <% end %>

      <%= widget %>
  """
  defmacro fragment(var, [do: body]) do
    quote do
      unquote(var) = unquote(body)
    end
  end

  defp classes_for_input(form, field, user_specified_classes) do
    case form.errors do
      [] ->
        user_specified_classes

      _other ->
        case Keyword.fetch(form.errors, field) do
          # The field contains an error
          {:ok, _error} ->
            [user_specified_classes, " is-invalid"]

          # The field doesn't contain an error
          :error ->
            [user_specified_classes, " is-valid"]
        end
    end
  end

  defp forage_generic_input(form, field, input_fun, opts, input_class) do
    {class, opts} = Keyword.pop(opts, :class, "")
    classes = classes_for_input(form, field, [class, " ", input_class])
    input_fun.(form, field, [{:class, classes} | opts])
  end

  phoenix_form_input_names = [
    :checkbox,
    :color_input,
    :date_input,
    :date_select,
    :datetime_local_input,
    :datetime_select,
    :email_input,
    :file_input,
    :input_type,
    :number_input,
    :password_input,
    :radio_button,
    :range_input,
    :search_input,
    :telephone_input,
    :text_input,
    :textarea,
    :time_input,
    :time_select,
    :url_input
  ]

  input_class_for = fn
    input when input in [:radio_button, :checkbox] -> "form-check-input"
    _other -> "form-control"
  end

  input_class_for_small = fn
    input when input in [:radio_button, :checkbox] -> "form-check-input form-check-input-sm"
    _other -> "form-control form-control-sm"
  end

  input_class_for_large = fn
    input when input in [:radio_button, :checkbox] -> "form-check-input form-check-input-lg"
    _other -> "form-control form-control-lg"
  end

  for name <- phoenix_form_input_names do
    forage_function_name = :"forage_#{name}"
    forage_function_name_small = :"forage_#{name}_small"
    forage_function_name_large = :"forage_#{name}_large"

    input_class = input_class_for.(name)
    input_class_small = input_class_for_small.(name)
    input_class_large = input_class_for_large.(name)

    @doc """
    See docs for `Phoenix.HTML.Form.#{name}/3`.
    """
    def unquote(forage_function_name)(form, field, opts \\ []) do
      forage_generic_input(form, field, &Form.unquote(name)/3, opts, unquote(input_class))
    end

    @doc """
    See docs for `Phoenix.HTML.Form.#{name}/3`.
    """
    def unquote(forage_function_name_small)(form, field, opts \\ []) do
      forage_generic_input(form, field, &Form.unquote(name)/3, opts, unquote(input_class_small))
    end

    @doc """
    See docs for `Phoenix.HTML.Form.#{name}/3`.
    """
    def unquote(forage_function_name_large)(form, field, opts \\ []) do
      forage_generic_input(form, field, &Form.unquote(name)/3, opts, unquote(input_class_large))
    end
  end


  @doc """
  Widget to select multiple external resources using the Javascript Select2 widget.

  Parameters:

    * `form` (`%Phoenix.Html.Form.t/1`)- the form
    * `field` (atom)
    * `path` - the URL from which to request the data

  Options:

    * `:foreign_key` (optional) - The name of the foreign key (as a string or an atom).
      If this is not supplied it will default to `field_id`
  """
  def forage_select(form, field, path, opts \\ []) do
    # Params
    foreign_key = Keyword.get(opts, :foreign_key, "#{field}_id")
    class = Keyword.get(opts, :class, "form-control")
    # Derived values
    field_value = input_value(form, field)
    field_id = field_value && Map.get(field_value, :id, nil)
    field_text = display_relation(field_value)

    ~e"""
    <select
      name="<%= form.name %>[<%= foreign_key %>]"
      class="<%= class %>"
      data-value="<%= field_id %>"
      data-forage-select2-widget="true"
      data-url="<%= path %>">
        <option value="<%= field_id %>"><%= field_text %></option>
    </select>
    """
  end

  @doc """
  Widget to select multiple external resources using the Javascript Select2 widget.

  Parameters:

    * `form` (`%Phoenix.Html.Form.t/1`)- the form
    * `field` (atom)

  Options:

    * `:foreign_key` (optional) - The name of the foreign key (as a string or an atom).
      If this is not supplied it will default to `"\#\{field\}_id"`
  """
  def forage_static_select(form, field, opts \\ []) do
    field_name_in_input =
      # There are three cases:
      case Keyword.get(opts, :foreign_key) do
        # The foreign key isn't given.
        # We assume this is a one-to-* relation and infer
        # the foreign key name accordingly
        nil -> "#{field}_id"
        # The user has specified that this field is not
        # a foreign relation and we don't have a foreign key.
        # In this case, we use the field name.
        false -> to_string(field)
        # The user has given an explicit foreign key.
        # We respect that choice.
        other -> to_string(other)
      end

    class = Keyword.get(opts, :class, "form-control")
    options = Keyword.fetch!(opts, :options)
    field_value = Map.get(form.data, field)
    field_id = get_field_id(field_value, :id)

    ~e"""
    <select name="<%= form.name %>[<%= field_name_in_input %>]" class="<%= class %>">
      <option></option>
      <%= for option <- options do %>
        <%= if Map.get(option, :id) == field_id do %>
          <option selected="selected" value="<%= options.id %>"><%= display_relation(option) %></option>
        <% else %>
          <option value="<%= option.id %>"><%= display_relation(option) %></option>
        <% end %>
      <% end %>
    </select>
    """
  end

  defp get_field_id(field_value, id_field) do
    case field_value do
      nil -> nil
      %NotLoaded{} -> nil
      value -> value && Map.get(value, id_field, nil)
    end
  end

  defp display_relation(nil), do: ""
  defp display_relation(%NotLoaded{} = _field), do: ""
  defp display_relation(%{__struct__: _} = field), do: ForageWeb.Display.as_text(field)

  @doc """
  Widget to select multiple external resources using the Javascript Select2 widget.

  Parameters:

    * `form` (`%Phoenix.Html.Form.t/1`)- the form
    * `field` (atom)
    * `path` (binary) - the URL from which to request the data

  Options:

    * `:foreign_key` (optional) - The name of the foreign key (as a string or an atom).
      If this is not supplied it will default to `"\#\{field\}_id"`
  """
  def forage_multiple_select(form, field, path, _opts) do
    # Derived values
    field_values =
      case Map.get(form.data, field) do
        %NotLoaded{} -> []
        other when is_list(other) -> other
      end

    results =
      for entry <- field_values do
        entry.id
      end

    # Try not to depend on Jason.encode!()
    rendered_initial_values = inspect(results)

    ~e"""
    <select
      multiple="true"
      name="<%= form.name %>[__forage_select_many__<%= to_string(field) %>][]"
      class="form-control"
      data-values="<%= rendered_initial_values %>"
      data-forage-select2-widget="true"
      data-url="<%= path %>">
      <%= for field_value <- field_values do %>
        <option selected="selected" value="<%= field_value && field_value.id %>"><%= display_relation(field_value) %></option>
      <% end %>
    </select>
    """
  end

  @doc """
  Widget to select an external resource using the Javascript Select2 widget.

  Parameters:

    * `form` (`%Phoenix.Html.Form.t/1`)- the form
    * `field` (atom)
    * `path` (binary) - the URL from which to request the data

  Options:

  * `:foreign_key` (optionsl) - The name of the foreign key (as a string or an atom).
     If this is not supplied it will default to `field_id`
  """
  def forage_select_filter(form, field, path, opts \\ []) do
    # Params
    class = Keyword.get(opts, :class, "")
    field_value = Map.get(form.data, field)
    field_id = field_value && Map.get(field_value, :id, nil)
    field_text = display_relation(field_value)

    ~e"""
    <div class="<%= class %>">
      <select
        name="_filter[<%= field %>_id][val]"
        class="form-control"
        data-forage-select2-widget="true"
        data-url="<%= path %>">
          <option value="<%= field_id %>"><%= field_text %></option>
      </select>
      <input type="hidden" name="_filter[<%= field %>_id][op]" value="equal_to"/>
    </div>
    """
  end

  # Find a way of internationalizing this
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

  @operator_class "col-sm-5"
  @value_class "col-sm-7"

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

  @doc """
  A link to sort a list of database rows by a certain key.
  """
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

  @doc """
  A link to the previous page of filter results.
  Returns the empty string if the previous page doesn't exist.
  """
  def forage_pagination_link_previous(conn, resource, mod, fun, contents) do
    if resource.metadata.before do
      before_params = Map.put(conn.params, :_pagination, %{before: resource.metadata.before})
      destination = apply(mod, fun, [conn, :index, before_params])
      ~e'<li class="page-item"><a class="page-link" href="<%= destination %>"><%= contents %></a></li>'
    else
      ~e''
    end
  end

  @doc """
  A link to the next page of filter results.
  Returns the empty string if the next page doesn't exist.
  """
  def forage_pagination_link_next(conn, resource, mod, fun, contents) do
    if resource.metadata.after do
      after_params = Map.put(conn.params, :_pagination, %{after: resource.metadata.after})
      destination = apply(mod, fun, [conn, :index, after_params])
      ~e'<li class="page-item"><a class="page-link" href="<%= destination %>"><%= contents %></a></li>'
    else
      ~e''
    end
  end

  @doc """
  An already styled "pagination widget" containing a link to the next page
  and to the previous page of filter results.

  If either the previous page or the next page doesn't exist,
  the respective link will be empty.

  TODO
  """
  def forage_pagination_widget(conn, resource, mod, fun, options) do
    previous_text = Keyword.get(options, :previous, "« Previous")
    next_text = Keyword.get(options, :next, "Next »")
    classes = Keyword.get(options, :classes, "justify-content-center")

    ~e"""
    <ul class="pagination <%= classes %>">
      <%= forage_pagination_link_previous conn, resource, mod, fun, previous_text %>
      <%= forage_pagination_link_next conn, resource, mod, fun, next_text %>
    </ul>
    """
  end

  @doc """
  Form group with support for internationalization.
  """
  def forage_form_group(form, field, label, error_helpers, opts \\ [], input_fun) do
    ~e"""
    <div class="form-group">
      <%= Form.label form, field, label, class: "form-label" %>
      <%= input_fun.(form, field, opts) %>
      <%= forage_error_tag(form, field, error_helpers) %>
    </div>
    """
  end

  @doc """
  Horizontal form group with support for internationalization by taking in
  the application's `error_helpers` module.

  *You shouldn't need to use this function directly*.
  You can use the `c:ForageWeb.ForageView.forage_form_group/5` callback
  defined in your view module, which impoements a specialized version
  of this function using your application's `error_helpers` module.
  """
  def forage_horizontal_form_group(form, field, label, error_helpers, opts, input_fun) when is_list(opts) do
    tight? = Keyword.get(opts, :tight, false)
    margin_bottom = (tight? && " mb-2") || ""
    {{label_class, inputs_class}, opts} = Keyword.pop(opts, :classes, {"col-sm-3 text-left", "col-sm-9"})
    full_label_class = label_class <> " col-form-label"

    ~e"""
    <div>
      <div class="form-group row<%= margin_bottom %>">
        <%= Form.label form, field, label, class: full_label_class %>
        <%= input_fun.(form, field, [{:class, inputs_class} | opts]) %>
        <div class="<%= label_class %>"></div>
        <%= forage_horizontal_error_tag(form, field, error_helpers, inputs_class) %>
      </div>
    </div>
    """
  end

  def forage_active_filters?(%{params: %{"_filter" => _}} = _conn), do: true

  def forage_active_filters?(_conn), do: false

  @spec forage_filter_form_for(
          FormData.t(),
          String.t(),
          Keyword.t(),
          (FormData.t() -> Phoenix.HTML.unsafe())
        ) :: Phoenix.HTML.safe()
  def forage_filter_form_for(conn, action, options \\ [], fun) do
    new_options =
      options
      |> Keyword.put_new(:as, :_filter)
      |> Keyword.put_new(:method, "get")

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

    filter_class = Keyword.get(opts, :class, "")
    {operator_class, value_class} = Keyword.get(opts, :filter_classes, {@operator_class, @value_class})

    ~e"""
    <div class="row <%= filter_class %>">
      <div class="<%= operator_class %>">
        <select name="_filter[<%= name %>][op]" class="form-control">
          <%= for {op_name, op_value} <- operators do %>
            <option value="<%= op_value %>"<%= if op_value == operator do %> selected="true"<% end %>><%= op_name %></option>
          <% end %>
        </select>
      </div>
      <div class="<%= value_class %>">
        <input type="<%= type %>" name="_filter[<%= name %>][val]" class="form-control" value="<%= value %>"></input>
      </div>
    </div>
    """
  end

  def forage_as_html(nil), do: ""
  def forage_as_html(%Ecto.Association.NotLoaded{}), do: "- not loaded -"
  def forage_as_html(resource), do: Display.as_html(resource)

  def forage_as_text(nil), do: ""
  def forage_as_text(%Ecto.Association.NotLoaded{}), do: "- not loaded -"
  def forage_as_text(resource), do: Display.as_text(resource)

  @doc """
  A filter that works on text.

  It supports the following operators:

    * Contains
    * Equal
    * Starts with
    * Ends with

  ## Examples

  TODO
  """
  def forage_text_filter(form, name, opts \\ []) do
    generic_forage_filter("text", form, name, @text_operators, opts)
  end

  @doc """
  A filter that works on numbers.

  It supports the following operators:

    * Equal to
    * Greater than
    * Less than
    * Greater than or equal to
    * Less than or equal to

  ## Examples

  TODO
  """
  def forage_numeric_filter(form, name, opts \\ []) do
    generic_forage_filter("number", form, name, @number_operators, opts)
  end

  @doc """
  A filter that works on dates.

  It supports the following operators:

    * Equal to
    * Greater than
    * Less than
    * Greater than or equal to
    * Less than or equal to

  ## Examples

  TODO
  """
  def forage_date_filter(form, name, opts \\ []) do
    generic_forage_filter("date", form, name, @number_operators, opts)
  end

  @doc """
  A filter that works on time.

  It supports the following operators:

    * Equal to
    * Greater than
    * Less than
    * Greater than or equal to
    * Less than or equal to

  ## Examples

  TODO
  """
  def forage_time_filter(form, name, opts \\ []) do
    generic_forage_filter("time", form, name, @number_operators, opts)
  end

  @doc """
  A filter that works on datetime objects.

  It supports the following operators:

    * Equal to
    * Greater than
    * Less than
    * Greater than or equal to
    * Less than or equal to

  ## Examples

  TODO
  """
  def forage_datetime_filter(form, name, opts \\ []) do
    generic_forage_filter("datetime", form, name, @number_operators, opts)
  end
end
