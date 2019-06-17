defmodule ForageWeb.Assets do
  @activate_select2 "<script>" <> File.read!("lib/forage_web/assets/select2.js") <> "</script>"
  @activate_datepicker "<script>" <>
                         File.read!("lib/forage_web/assets/datepicker.js") <> "</script>"
  @forage_date_input_assets """
  <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/css/bootstrap-datepicker.min.css" rel="stylesheet"/>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/js/bootstrap-datepicker.min.js"></script>
  """
  @forage_select_assets """
  <link href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.6-rc.0/css/select2.min.css" rel="stylesheet" />
  <script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.6-rc.0/js/select2.min.js"></script>
  """

  def forage_date_input_assets() do
    {:safe, @forage_date_input_assets}
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
