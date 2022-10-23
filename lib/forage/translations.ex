defmodule Forage.Translations do
  @moduledoc """
  TODO
  """
  require ExUnit.Assertions, as: Assertions

  defmacro translated_enum(name, gettext_backend, gettext_domain, options) do
    do_translated_enum(name, gettext_backend, gettext_domain, options)
  end

  defmacro translated_enums(gettext_backend, gettext_domain, enums) do
    clauses =
      for {name, options} <- enums do
        do_translated_enum(name, gettext_backend, gettext_domain, options)
      end

    quote do
      unquote_splicing(clauses)
    end
  end

  @doc false
  def do_translated_enum(name, gettext_backend, gettext_domain, options) do
    show_name = :"show_#{name}"
    options_for_name = :"options_for_#{name}"
    non_empty_options_for_name = :"non_empty_valid_values_for_#{name}"
    valid_values = :"valid_values_for_#{name}"

    for {external, internal} <- options do
      Assertions.assert(is_binary(internal))
      Assertions.assert(is_atom(external) or is_binary(external))
    end

    non_empty_i18n_options =
      for {external, internal} <- options do
        key =
          quote do
            unquote(gettext_backend).dgettext(
              unquote(gettext_domain),
              unquote(to_string(external))
            )
          end

        value = to_string(internal)

        {key, value}
      end

    i18n_options = ["": ""] ++ non_empty_i18n_options

    # No need to quote; quoted lists of strings are lists of strings
    non_empty_options = for {_external, internal} <- options, do: internal
    valid_options = [""] ++ non_empty_options

    valid_values_func_def =
      quote do
        def unquote(valid_values)() do
          unquote(valid_options)
        end
      end

    non_empty_valid_values_def =
      quote do
        def unquote(non_empty_options_for_name)() do
          unquote(non_empty_options)
        end
      end

    options_func_def =
      quote do
        def unquote(options_for_name)() do
          unquote(i18n_options)
        end
      end

    valid_show_func_defs =
      for {external, internal} <- options do
        quote do
          def unquote(show_name)(unquote(internal)) do
            unquote(gettext_backend).dgettext(
              unquote(gettext_domain),
              unquote(to_string(external))
            )
          end
        end
      end

    catch_all_show_func_def =
      quote do
        def unquote(show_name)(other), do: other
      end

    show_func_defs = valid_show_func_defs ++ [catch_all_show_func_def]

    quote do
      require unquote(gettext_backend)

      @doc """
      Non possible valid values for the `:#{unquote(name)}` field
      (including the empty string).
      """
      unquote(valid_values_func_def)

      @doc """
      Non empty valid values for the `:#{unquote(name)}` field.
      """
      unquote(non_empty_valid_values_def)

      @doc """
      All options in the form of pairs such as `{user_visible_name, value}`
      for the `:#{unquote(name)}` field.
      """
      unquote(options_func_def)

      @doc """
      Shows the internationalized user-visible value.

      TODO: explain this better.
      """
      unquote_splicing(show_func_defs)
    end
  end
end
