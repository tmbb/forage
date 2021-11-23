defmodule ForageWeb.Assets do
  @moduledoc """
  Static assets for mandarin pages.
  """
  @external_resource "lib/forage_web/assets/select2.js"
  @external_resource "lib/forage_web/assets/datepicker.js"

  @activate_select2 "<script>" <> File.read!("lib/forage_web/assets/select2.js") <> "</script>"
  @activate_datepicker "<script>" <>
                         File.read!("lib/forage_web/assets/datepicker.js") <> "</script>"
  @forage_date_input_assets """
  <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/css/bootstrap-datepicker.min.css" rel="stylesheet"/>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/js/bootstrap-datepicker.min.js" defer></script>
  """
  @forage_select_assets """
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@ttskch/select2-bootstrap4-theme/dist/select2-bootstrap4.min.css"/>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/js/select2.min.js"></script>
  """

  def forage_date_input_assets(opts \\ []) do
    languages = Keyword.get(opts, :languages, [])
    locales_to_include =
      for language <- languages do
        [
          ~s[<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/locales/bootstrap-datepicker.],
          Atom.to_string(language),
          ~s[.min.js"></script>\n]
        ]
      end

    {:safe, [@forage_date_input_assets, "\n", locales_to_include]}
  end

  def forage_select_assets() do
    {:safe, @forage_select_assets}
  end

  def activate_forage_date_input() do
    {:safe, @activate_datepicker}
  end

  def activate_forage_select() do
    {:safe, @activate_select2}
  end
end
