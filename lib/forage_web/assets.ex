defmodule ForageWeb.Assets do
  @moduledoc """
  Static assets for mandarin pages.
  """
  @external_resource "lib/forage_web/assets/select2.js"
  @external_resource "lib/forage_web/assets/datepicker.js"

  bootswatch_themes = ~w(
    cerulean
    cosmo
    cyborg
    darkly
    flatly
    journal
    litera
    lumen
    lux
    materia
    minty
    pulse
    sandstone
    simplex
    sketchy
    slate
    solar
    spacelab
    superhero
    united
    yeti
  )

  @bootswatch_themes bootswatch_themes

  url_for_theme =
    fn theme ->
      "https://bootswatch.com/#{theme}/"
    end

  theme_list_markdown =
    bootswatch_themes
    |> Enum.map(fn theme -> "  - [#{theme}](#{url_for_theme.(theme)})" end)
    |> Enum.join("\n")

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

  @doc """
  Adds a `<script>` tag to the webpage with the javascript required to run
  the fancy datepicker select widgets.
  Even after adding this code, you need to activate the select widget using
  `ForageWeb.Assets.activate_date_input()`

  The Javascript is loaded from an external CDN.
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

  @doc """
  Add to the end of the webpage in order to activate the fancy datepicker widget.
  Adds a `<script>` tag to the webpage.

  The Javascript is loaded from an external CDN.
  """
  def activate_forage_date_input() do
    {:safe, @activate_datepicker}
  end

  @doc """
  Adds a `<script>` tag to the webpage with the javascript required to run
  the forage select widgets.
  Even after adding this code, you need to activate the select widget using
  `ForageWeb.Assets.activate_forage_select()`

  The Javascript is loaded from an external CDN.
  """
  def forage_select_assets() do
    {:safe, @forage_select_assets}
  end

  @doc """
  Add to the end of the webpage in order to activate the fancy datepicker widget.
  Adds a `<script>` tag to the webpage.

  The Javascript is loaded from an external CDN.
  """
  def activate_forage_select() do
    {:safe, @activate_select2}
  end

  @doc """
  Renders the HTML necessary to use a given Bootswatch4 theme.

  The following themes are supported:

  #{theme_list_markdown}

  Note: no specific endorsement of Bootswatch themes is intended.
  They are included here simply becuase they are compatible with
  the default theme and may be a simple way of adding variety
  to your website.

  ## Examples

  ```heex
  <%= ForageWeb.Assets.theme_from_cdn("superhero") %>
  ```
  """
  def theme_from_cdn("default") do
    {:safe, ~S[<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/css/bootstrap.min.css">]}
  end

  def theme_from_cdn(theme) when theme in @bootswatch_themes do
    {:safe, [
      ~S[<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootswatch@4.5.2/dist/],
      theme,
      ~S[/bootstrap.min.css">]
      ]}
  end
end
