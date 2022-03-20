defmodule Forage.Scripts.GenerateWidgetTests do
  require EEx

  @input_based_widget_data [
    {:color_input, :color_field},
    {:date_input, :date_field},
    {:email_input, :email_field},
    {:number_input, :number_field},
    {:password_input, :string_field},
    {:range_input, :number_field},
    {:search_input, :string_field},
    {:text_input, :string_field},
    {:time_input, :time_field},
    {:url_input, :url_input}
  ]


  _others_already_added = [
    :telephone_input,
    :checkbox,
    :radio_button
  ]

  _others_not_yet_added = [
    :textarea,
    :date_select,
    :datetime_local_input,
    :datetime_select,
    :file_input,
    :input_type,
    :radio_button,
    :time_select,
  ]


  @external_resource "scripts/templates/forage_widget_tests.ex"
  EEx.function_from_file(
    :defp,
    :render_tests,
    "scripts/templates/forage_widget_test.exs",
    [:assigns]
  )

  defp input_type(widget_name) do
    widget_name
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.at(0)
  end

  def run() do
    input_based_widget_data =
      for {widget_name, field_name} <- @input_based_widget_data do
        {widget_name, input_type(widget_name), field_name}
      end

    input_based_widget_data =
      input_based_widget_data ++ [
        {:telephone_input, "tel", :telephone_field}
      ]

    content =
      render_tests(
        input_based_widget_data: input_based_widget_data
      )

    File.write!("test/forage_web/forage_view/forage_widget_test.exs", content)
  end
end

Forage.Scripts.GenerateWidgetTests.run()
