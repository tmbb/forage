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
    test "sanity check on color_input widgets (small, normal and large)" do
      form = test_form()

      safe_html_small = ForageView.forage_color_input_small(form, :color_field, [])
      safe_html_normal = ForageView.forage_color_input(form, :color_field, [])
      safe_html_large = ForageView.forage_color_input_large(form, :color_field, [])

      html_small = to_html(safe_html_small)
      html_normal = to_html(safe_html_normal)
      html_large = to_html(safe_html_large)

      {:ok, doc_small} = Floki.parse_fragment(html_small)
      {:ok, doc_normal} = Floki.parse_fragment(html_normal)
      {:ok, doc_large} = Floki.parse_fragment(html_large)

      # Small widget
      assert [_input] = Floki.find(doc_small, "input.form-control.form-control-sm")
      assert Floki.find(doc_small, "input") |> Floki.attribute("type") == ["color"]

      # Normal widget
      assert [_input] = Floki.find(doc_normal, "input.form-control")
      assert Floki.find(doc_normal, "input") |> Floki.attribute("type") == ["color"]

      # Large widget
      assert [_input] = Floki.find(doc_large, "input.form-control.form-control-lg")
      assert Floki.find(doc_large, "input") |> Floki.attribute("type") == ["color"]
    end

    test "sanity check on date_input widgets (small, normal and large)" do
      form = test_form()

      safe_html_small = ForageView.forage_date_input_small(form, :date_field, [])
      safe_html_normal = ForageView.forage_date_input(form, :date_field, [])
      safe_html_large = ForageView.forage_date_input_large(form, :date_field, [])

      html_small = to_html(safe_html_small)
      html_normal = to_html(safe_html_normal)
      html_large = to_html(safe_html_large)

      {:ok, doc_small} = Floki.parse_fragment(html_small)
      {:ok, doc_normal} = Floki.parse_fragment(html_normal)
      {:ok, doc_large} = Floki.parse_fragment(html_large)

      # Small widget
      assert [_input] = Floki.find(doc_small, "input.form-control.form-control-sm")
      assert Floki.find(doc_small, "input") |> Floki.attribute("type") == ["date"]

      # Normal widget
      assert [_input] = Floki.find(doc_normal, "input.form-control")
      assert Floki.find(doc_normal, "input") |> Floki.attribute("type") == ["date"]

      # Large widget
      assert [_input] = Floki.find(doc_large, "input.form-control.form-control-lg")
      assert Floki.find(doc_large, "input") |> Floki.attribute("type") == ["date"]
    end

    test "sanity check on email_input widgets (small, normal and large)" do
      form = test_form()

      safe_html_small = ForageView.forage_email_input_small(form, :email_field, [])
      safe_html_normal = ForageView.forage_email_input(form, :email_field, [])
      safe_html_large = ForageView.forage_email_input_large(form, :email_field, [])

      html_small = to_html(safe_html_small)
      html_normal = to_html(safe_html_normal)
      html_large = to_html(safe_html_large)

      {:ok, doc_small} = Floki.parse_fragment(html_small)
      {:ok, doc_normal} = Floki.parse_fragment(html_normal)
      {:ok, doc_large} = Floki.parse_fragment(html_large)

      # Small widget
      assert [_input] = Floki.find(doc_small, "input.form-control.form-control-sm")
      assert Floki.find(doc_small, "input") |> Floki.attribute("type") == ["email"]

      # Normal widget
      assert [_input] = Floki.find(doc_normal, "input.form-control")
      assert Floki.find(doc_normal, "input") |> Floki.attribute("type") == ["email"]

      # Large widget
      assert [_input] = Floki.find(doc_large, "input.form-control.form-control-lg")
      assert Floki.find(doc_large, "input") |> Floki.attribute("type") == ["email"]
    end

    test "sanity check on number_input widgets (small, normal and large)" do
      form = test_form()

      safe_html_small = ForageView.forage_number_input_small(form, :number_field, [])
      safe_html_normal = ForageView.forage_number_input(form, :number_field, [])
      safe_html_large = ForageView.forage_number_input_large(form, :number_field, [])

      html_small = to_html(safe_html_small)
      html_normal = to_html(safe_html_normal)
      html_large = to_html(safe_html_large)

      {:ok, doc_small} = Floki.parse_fragment(html_small)
      {:ok, doc_normal} = Floki.parse_fragment(html_normal)
      {:ok, doc_large} = Floki.parse_fragment(html_large)

      # Small widget
      assert [_input] = Floki.find(doc_small, "input.form-control.form-control-sm")
      assert Floki.find(doc_small, "input") |> Floki.attribute("type") == ["number"]

      # Normal widget
      assert [_input] = Floki.find(doc_normal, "input.form-control")
      assert Floki.find(doc_normal, "input") |> Floki.attribute("type") == ["number"]

      # Large widget
      assert [_input] = Floki.find(doc_large, "input.form-control.form-control-lg")
      assert Floki.find(doc_large, "input") |> Floki.attribute("type") == ["number"]
    end

    test "sanity check on password_input widgets (small, normal and large)" do
      form = test_form()

      safe_html_small = ForageView.forage_password_input_small(form, :string_field, [])
      safe_html_normal = ForageView.forage_password_input(form, :string_field, [])
      safe_html_large = ForageView.forage_password_input_large(form, :string_field, [])

      html_small = to_html(safe_html_small)
      html_normal = to_html(safe_html_normal)
      html_large = to_html(safe_html_large)

      {:ok, doc_small} = Floki.parse_fragment(html_small)
      {:ok, doc_normal} = Floki.parse_fragment(html_normal)
      {:ok, doc_large} = Floki.parse_fragment(html_large)

      # Small widget
      assert [_input] = Floki.find(doc_small, "input.form-control.form-control-sm")
      assert Floki.find(doc_small, "input") |> Floki.attribute("type") == ["password"]

      # Normal widget
      assert [_input] = Floki.find(doc_normal, "input.form-control")
      assert Floki.find(doc_normal, "input") |> Floki.attribute("type") == ["password"]

      # Large widget
      assert [_input] = Floki.find(doc_large, "input.form-control.form-control-lg")
      assert Floki.find(doc_large, "input") |> Floki.attribute("type") == ["password"]
    end

    test "sanity check on range_input widgets (small, normal and large)" do
      form = test_form()

      safe_html_small = ForageView.forage_range_input_small(form, :number_field, [])
      safe_html_normal = ForageView.forage_range_input(form, :number_field, [])
      safe_html_large = ForageView.forage_range_input_large(form, :number_field, [])

      html_small = to_html(safe_html_small)
      html_normal = to_html(safe_html_normal)
      html_large = to_html(safe_html_large)

      {:ok, doc_small} = Floki.parse_fragment(html_small)
      {:ok, doc_normal} = Floki.parse_fragment(html_normal)
      {:ok, doc_large} = Floki.parse_fragment(html_large)

      # Small widget
      assert [_input] = Floki.find(doc_small, "input.form-control.form-control-sm")
      assert Floki.find(doc_small, "input") |> Floki.attribute("type") == ["range"]

      # Normal widget
      assert [_input] = Floki.find(doc_normal, "input.form-control")
      assert Floki.find(doc_normal, "input") |> Floki.attribute("type") == ["range"]

      # Large widget
      assert [_input] = Floki.find(doc_large, "input.form-control.form-control-lg")
      assert Floki.find(doc_large, "input") |> Floki.attribute("type") == ["range"]
    end

    test "sanity check on search_input widgets (small, normal and large)" do
      form = test_form()

      safe_html_small = ForageView.forage_search_input_small(form, :string_field, [])
      safe_html_normal = ForageView.forage_search_input(form, :string_field, [])
      safe_html_large = ForageView.forage_search_input_large(form, :string_field, [])

      html_small = to_html(safe_html_small)
      html_normal = to_html(safe_html_normal)
      html_large = to_html(safe_html_large)

      {:ok, doc_small} = Floki.parse_fragment(html_small)
      {:ok, doc_normal} = Floki.parse_fragment(html_normal)
      {:ok, doc_large} = Floki.parse_fragment(html_large)

      # Small widget
      assert [_input] = Floki.find(doc_small, "input.form-control.form-control-sm")
      assert Floki.find(doc_small, "input") |> Floki.attribute("type") == ["search"]

      # Normal widget
      assert [_input] = Floki.find(doc_normal, "input.form-control")
      assert Floki.find(doc_normal, "input") |> Floki.attribute("type") == ["search"]

      # Large widget
      assert [_input] = Floki.find(doc_large, "input.form-control.form-control-lg")
      assert Floki.find(doc_large, "input") |> Floki.attribute("type") == ["search"]
    end

    test "sanity check on text_input widgets (small, normal and large)" do
      form = test_form()

      safe_html_small = ForageView.forage_text_input_small(form, :string_field, [])
      safe_html_normal = ForageView.forage_text_input(form, :string_field, [])
      safe_html_large = ForageView.forage_text_input_large(form, :string_field, [])

      html_small = to_html(safe_html_small)
      html_normal = to_html(safe_html_normal)
      html_large = to_html(safe_html_large)

      {:ok, doc_small} = Floki.parse_fragment(html_small)
      {:ok, doc_normal} = Floki.parse_fragment(html_normal)
      {:ok, doc_large} = Floki.parse_fragment(html_large)

      # Small widget
      assert [_input] = Floki.find(doc_small, "input.form-control.form-control-sm")
      assert Floki.find(doc_small, "input") |> Floki.attribute("type") == ["text"]

      # Normal widget
      assert [_input] = Floki.find(doc_normal, "input.form-control")
      assert Floki.find(doc_normal, "input") |> Floki.attribute("type") == ["text"]

      # Large widget
      assert [_input] = Floki.find(doc_large, "input.form-control.form-control-lg")
      assert Floki.find(doc_large, "input") |> Floki.attribute("type") == ["text"]
    end

    test "sanity check on time_input widgets (small, normal and large)" do
      form = test_form()

      safe_html_small = ForageView.forage_time_input_small(form, :time_field, [])
      safe_html_normal = ForageView.forage_time_input(form, :time_field, [])
      safe_html_large = ForageView.forage_time_input_large(form, :time_field, [])

      html_small = to_html(safe_html_small)
      html_normal = to_html(safe_html_normal)
      html_large = to_html(safe_html_large)

      {:ok, doc_small} = Floki.parse_fragment(html_small)
      {:ok, doc_normal} = Floki.parse_fragment(html_normal)
      {:ok, doc_large} = Floki.parse_fragment(html_large)

      # Small widget
      assert [_input] = Floki.find(doc_small, "input.form-control.form-control-sm")
      assert Floki.find(doc_small, "input") |> Floki.attribute("type") == ["time"]

      # Normal widget
      assert [_input] = Floki.find(doc_normal, "input.form-control")
      assert Floki.find(doc_normal, "input") |> Floki.attribute("type") == ["time"]

      # Large widget
      assert [_input] = Floki.find(doc_large, "input.form-control.form-control-lg")
      assert Floki.find(doc_large, "input") |> Floki.attribute("type") == ["time"]
    end

    test "sanity check on url_input widgets (small, normal and large)" do
      form = test_form()

      safe_html_small = ForageView.forage_url_input_small(form, :url_input, [])
      safe_html_normal = ForageView.forage_url_input(form, :url_input, [])
      safe_html_large = ForageView.forage_url_input_large(form, :url_input, [])

      html_small = to_html(safe_html_small)
      html_normal = to_html(safe_html_normal)
      html_large = to_html(safe_html_large)

      {:ok, doc_small} = Floki.parse_fragment(html_small)
      {:ok, doc_normal} = Floki.parse_fragment(html_normal)
      {:ok, doc_large} = Floki.parse_fragment(html_large)

      # Small widget
      assert [_input] = Floki.find(doc_small, "input.form-control.form-control-sm")
      assert Floki.find(doc_small, "input") |> Floki.attribute("type") == ["url"]

      # Normal widget
      assert [_input] = Floki.find(doc_normal, "input.form-control")
      assert Floki.find(doc_normal, "input") |> Floki.attribute("type") == ["url"]

      # Large widget
      assert [_input] = Floki.find(doc_large, "input.form-control.form-control-lg")
      assert Floki.find(doc_large, "input") |> Floki.attribute("type") == ["url"]
    end

    test "sanity check on telephone_input widgets (small, normal and large)" do
      form = test_form()

      safe_html_small = ForageView.forage_telephone_input_small(form, :telephone_field, [])
      safe_html_normal = ForageView.forage_telephone_input(form, :telephone_field, [])
      safe_html_large = ForageView.forage_telephone_input_large(form, :telephone_field, [])

      html_small = to_html(safe_html_small)
      html_normal = to_html(safe_html_normal)
      html_large = to_html(safe_html_large)

      {:ok, doc_small} = Floki.parse_fragment(html_small)
      {:ok, doc_normal} = Floki.parse_fragment(html_normal)
      {:ok, doc_large} = Floki.parse_fragment(html_large)

      # Small widget
      assert [_input] = Floki.find(doc_small, "input.form-control.form-control-sm")
      assert Floki.find(doc_small, "input") |> Floki.attribute("type") == ["tel"]

      # Normal widget
      assert [_input] = Floki.find(doc_normal, "input.form-control")
      assert Floki.find(doc_normal, "input") |> Floki.attribute("type") == ["tel"]

      # Large widget
      assert [_input] = Floki.find(doc_large, "input.form-control.form-control-lg")
      assert Floki.find(doc_large, "input") |> Floki.attribute("type") == ["tel"]
    end
  end
end
