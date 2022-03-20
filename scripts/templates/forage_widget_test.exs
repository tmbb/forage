defmodule Forage.ForageView.InputWidgetTests do
  use ExUnit.Case, async: true
  alias ForageWeb.ForageView

  # Some example data
  @string_field_value "A string"
  @boolean_field_value true
  @number_field_value 337
  @date_field_value Date.new!(2022, 3, 12)
  @time_field_value Time.new!(12, 45, 00)
  @telephone_field_value "555-505-555"
  @color_field_value "#aa11bb"

  defp test_form() do
    # Random URL because we need to build the conn out of something
    Plug.Test.conn(:get, "/", %{
      string_field: @string_field_value,
      boolean_field: @boolean_field_value,
      number_field: @number_field_value,
      date_field: @date_field_value,
      time_field: @time_field_value,
      color_field: @color_field_value,
      telephone_field: @telephone_field_value
    })
    |> Phoenix.HTML.FormData.to_form([])
  end

  defp to_html(rendered) do
    # Convert "safe HTML" into raw HTML that can be analyzed by Floki
    rendered
    |> Phoenix.HTML.Safe.to_iodata()
    |> to_string()
  end

  test "sanity check on checkbox radio button widget (small, normal and large)" do
    form = test_form()

    safe_html_small = ForageView.forage_radio_button_small(form, :string_field, "A string", [])
    safe_html_normal = ForageView.forage_radio_button(form, :string_field, "A string", [])
    safe_html_large = ForageView.forage_radio_button_large(form, :string_field, "A string", [])

    html_small = to_html(safe_html_small)
    html_normal = to_html(safe_html_normal)
    html_large = to_html(safe_html_large)

    {:ok, doc_small} = Floki.parse_fragment(html_small)
    {:ok, doc_normal} = Floki.parse_fragment(html_normal)
    {:ok, doc_large} = Floki.parse_fragment(html_large)

    # Small widget
    assert [_input] = Floki.find(doc_small, "input.form-check-input.form-check-input-sm")
    assert Floki.find(doc_small, "input") |> Floki.attribute("type") == ["radio"]

    # Normal widget
    assert [_input] = Floki.find(doc_normal, "input.form-check-input")
    assert Floki.find(doc_normal, "input") |> Floki.attribute("type") == ["radio"]
    # Large widget
    assert [_input] = Floki.find(doc_large, "input.form-check-input.form-check-input-lg")
    assert Floki.find(doc_large, "input") |> Floki.attribute("type") == ["radio"]
  end

  test "sanity check on checkbox widgets (small, normal and large)" do
    form = test_form()

    safe_html_small = ForageView.forage_checkbox_small(form, :boolean_field, [])
    safe_html_normal = ForageView.forage_checkbox(form, :boolean_field, [])
    safe_html_large = ForageView.forage_checkbox_large(form, :boolean_field, [])

    html_small = to_html(safe_html_small)
    html_normal = to_html(safe_html_normal)
    html_large = to_html(safe_html_large)

    {:ok, doc_small} = Floki.parse_fragment(html_small)
    {:ok, doc_normal} = Floki.parse_fragment(html_normal)
    {:ok, doc_large} = Floki.parse_fragment(html_large)

    # Small widget
    assert [_input] = Floki.find(doc_small, "input.form-check-input.form-check-input-sm")
    assert Floki.find(doc_small, "input") |> Floki.attribute("type") == ["hidden", "checkbox"]

    # Normal widget
    assert [_input] = Floki.find(doc_normal, "input.form-check-input")
    assert Floki.find(doc_normal, "input") |> Floki.attribute("type") == ["hidden", "checkbox"]

    # Large widget
    assert [_input] = Floki.find(doc_large, "input.form-check-input.form-check-input-lg")
    assert Floki.find(doc_large, "input") |> Floki.attribute("type") == ["hidden", "checkbox"]
  end

  describe "widgets based on the HTML <input> element:" do
<%= for {widget_name, input_type, field_name} <- @input_based_widget_data do %>
    test "sanity check on <%= widget_name %> widgets (small, normal and large)" do
      form = test_form()

      safe_html_small = ForageView.forage_<%= widget_name %>_small(form, <%= inspect(field_name) %>, [])
      safe_html_normal = ForageView.forage_<%= widget_name %>(form, <%= inspect(field_name) %>, [])
      safe_html_large = ForageView.forage_<%= widget_name %>_large(form, <%= inspect(field_name) %>, [])

      html_small = to_html(safe_html_small)
      html_normal = to_html(safe_html_normal)
      html_large = to_html(safe_html_large)

      {:ok, doc_small} = Floki.parse_fragment(html_small)
      {:ok, doc_normal} = Floki.parse_fragment(html_normal)
      {:ok, doc_large} = Floki.parse_fragment(html_large)

      # Small widget
      assert [_input] = Floki.find(doc_small, "input.form-control.form-control-sm")
      assert Floki.find(doc_small, "input") |> Floki.attribute("type") == [<%= inspect(to_string(input_type)) %>]

      # Normal widget
      assert [_input] = Floki.find(doc_normal, "input.form-control")
      assert Floki.find(doc_normal, "input") |> Floki.attribute("type") == [<%= inspect(to_string(input_type)) %>]

      # Large widget
      assert [_input] = Floki.find(doc_large, "input.form-control.form-control-lg")
      assert Floki.find(doc_large, "input") |> Floki.attribute("type") == [<%= inspect(to_string(input_type)) %>]
    end
<% end %>
  end
end
