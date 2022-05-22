defmodule Forage.Test.ForageWeb.ForageView.ForageFormGroupTest do
  use ExUnit.Case, async: true
  # import ForageWeb.ForageView
  alias ForageWeb.ForageView

  # Get a view build using `use ForageWeb.ForageView` so we can test
  # the automatically defined callbacks
  alias Forage.Test.SupportWeb.Org.EmployeeView

  alias Forage.Test.SupportWeb.ErrorHelpers

  @string_field_value "A string"
  @boolean_field_value true

  defp test_conn(params) do
    Plug.Test.conn(:get, "/", params)
  end

  defp test_form() do
    test_conn(%{
      string_field: @string_field_value,
      boolean_field: @boolean_field_value
    })
    |> Phoenix.HTML.FormData.to_form([])
  end

  def to_html(rendered) do
    rendered
    |> Phoenix.HTML.Safe.to_iodata()
    |> to_string()
  end

  describe "internationalized form groups - forage_form_group:" do
    test "sanity check on MyView.forage_form_group/5 output" do
      safe_html =
        EmployeeView.forage_form_group(
          test_form(),
          :string_field,
          "String field label",
          [],
          &ForageView.forage_text_input/3
        )

      html = to_html(safe_html)

      {:ok, doc} = Floki.parse_fragment(html)

      assert [_div] = Floki.find(doc, "div.form-group")
      assert [_label] = Floki.find(doc, "div > label.form-label")
      assert Floki.find(doc, "div > label") |> Floki.attribute("for") == ["string_field"]
      assert Floki.find(doc, "div > label") |> Floki.text() == "String field label"
      assert [_input] = Floki.find(doc, "div > input.form-control")
      assert Floki.find(doc, "div > input") |> Floki.attribute("value") == ["A string"]
      assert Floki.find(doc, "div > input") |> Floki.text() == ""
    end

    test "MyView.forage_form_group/5 is equivalent to ForageView.forage_form_group/6" do
      # Function specialized for a given view
      safe_html5 =
        EmployeeView.forage_form_group(
          test_form(),
          :string_field,
          "String field label",
          [],
          &ForageView.forage_text_input/3
        )

      # Generic function
      safe_html6 =
        ForageView.forage_form_group(
          test_form(),
          :string_field,
          "String field label",
          ErrorHelpers,
          [],
          &ForageView.forage_text_input/3
        )

      # The output should be the same
      assert safe_html5 == safe_html6
    end
  end

  describe "internationalized form groups - forage_horizontal_form_group:" do
    test "sanity check on MyView.forage_horizontal_form_group/5 output" do
      safe_html =
        EmployeeView.forage_horizontal_form_group(
          test_form(),
          :string_field,
          "String field label",
          [],
          &ForageView.forage_text_input/3
        )

      html = to_html(safe_html)

      {:ok, doc} = Floki.parse_fragment(html)

      assert [_div] = Floki.find(doc, "div.form-group.row")
      assert [_label] = Floki.find(doc, "div > label.col-form-label")
      assert Floki.find(doc, "div > label") |> Floki.attribute("for") == ["string_field"]
      assert Floki.find(doc, "div > label") |> Floki.text() == "String field label"
      assert [_input] = Floki.find(doc, "div > input.form-control")
      assert Floki.find(doc, "div > input") |> Floki.attribute("value") == ["A string"]
      assert Floki.find(doc, "div > input") |> Floki.text() == ""
    end

    test "MyView.forage_form_group/5 is equivalent to ForageView.forage_form_group/6" do
      # Function specialized for a given view
      safe_html5 =
        EmployeeView.forage_horizontal_form_group(
          test_form(),
          :string_field,
          "String field label",
          [],
          &ForageView.forage_text_input/3
        )

      # Generic function
      safe_html6 =
        ForageView.forage_horizontal_form_group(
          test_form(),
          :string_field,
          "String field label",
          ErrorHelpers,
          [],
          &ForageView.forage_text_input/3
        )

      # The output should be the same
      assert safe_html5 == safe_html6
    end
  end

  describe "internationalized form groups - forage_form_check:" do
    test "sanity check on MyView.forage_form_check/5 output" do
      safe_html =
        EmployeeView.forage_form_check(
          test_form(),
          :boolean_field,
          "Boolean field label",
          [],
          &ForageView.forage_checkbox/3
        )

      html = to_html(safe_html)

      {:ok, doc} = Floki.parse_fragment(html)

      assert [_div] = Floki.find(doc, "div.form-check")
      assert [_label] = Floki.find(doc, "div > label.form-check-label")
      assert Floki.find(doc, "div > label") |> Floki.attribute("for") == ["boolean_field"]
      assert Floki.find(doc, "div > label") |> Floki.text() == "Boolean field label"
      assert [_input] = Floki.find(doc, "div > input.form-check-input")
      # Don't forgett that the checkbox widgets generate an extra hidden input!
      assert Floki.find(doc, "div > input") |> Floki.attribute("value") == ["false", "true"]
    end

    test "MyView.forage_form_check/5 is equivalent to ForageView.forage_form_check/6" do
      # Function specialized for a given view
      safe_html5 =
        EmployeeView.forage_form_check(
          test_form(),
          :string_field,
          "String field label",
          [],
          &ForageView.forage_checkbox/3
        )

      # Generic function
      safe_html6 =
        ForageView.forage_form_check(
          test_form(),
          :string_field,
          "String field label",
          ErrorHelpers,
          [],
          &ForageView.forage_checkbox/3
        )

      # The output should be the same
      assert safe_html5 == safe_html6
    end
  end
end
