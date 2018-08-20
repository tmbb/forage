defmodule Forage.Codec.RoundtripTest do
  use ExUnit.Case, async: true
  alias Forage.Codec.Encoder
  alias Forage.Codec.Decoder
  alias Forage.ForagePlan
  # Exceptions
  alias Forage.Codec.Exceptions.InvalidFieldError
  alias Forage.Codec.Exceptions.InvalidSortDirectionError
  # Testing hepers
  alias TestSchemas.DummySchema
  doctest Forage.Codec.Encoder

  describe "search" do
    test "single search filter" do
      encoded =
        %{"search" => %{
            "string_field" => %{
              "operator" => "contains",
              "value" => "x"}}}

      decoded =
        ForagePlan.new(search: [[field: :string_field, operator: "contains", value: "x"]])

      assert Encoder.encode(decoded) == encoded
      assert Decoder.decode(DummySchema, encoded) == decoded
    end

    test "multiple search filters" do
      encoded =
        %{"search" => %{
            "string_field" => %{
              "operator" => "contains",
              "value" => "x"},
            "integer_field" => %{
              "operator" => "equal_to",
              "value" => "2"}}}

      decoded =
        ForagePlan.new(search: [
          [field: :integer_field, operator: "equal_to", value: "2"],
          [field: :string_field, operator: "contains", value: "x"]
        ])

      assert Encoder.encode(decoded) == encoded
      assert Decoder.decode(DummySchema, encoded) == decoded
    end

    test "multiple decoding runs preserve the order of the filters" do
      # Search filters are converted into keyword lists.
      # Those keyword lists must be ordered so that the decoder is referentially transparent.
      encoded =
        %{"search" => %{
            "string_field" => %{
              "operator" => "contains",
              "value" => "x"},
            "integer_field" => %{
              "operator" => "equal_to",
              "value" => "2"}}}

      decoded =
        ForagePlan.new(search: [
          [field: :integer_field, operator: "equal_to", value: "2"],
          [field: :string_field, operator: "contains", value: "x"]
        ])

      decoded_wrong_order =
        ForagePlan.new(search: [
          [field: :string_field, operator: "contains", value: "x"],
          [field: :integer_field, operator: "equal_to", value: "2"]
        ])

      for _ <- 1..100 do
        assert Decoder.decode(DummySchema, encoded) == decoded
        # Completely unnecessary but self-documenting
        assert Decoder.decode(DummySchema, encoded) != decoded_wrong_order
      end
    end
  end

  describe "sort" do
    test "single sort field" do
      # Ascending order
      encoded_asc = %{"sort" => %{"string_field" => %{"direction" => "asc"}}}
      decoded_asc = ForagePlan.new(sort: [[field: :string_field, direction: :asc]])
      # Descending order
      encoded_desc = %{"sort" => %{"string_field" => %{"direction" => "desc"}}}
      decoded_desc = ForagePlan.new(sort: [[field: :string_field, direction: :desc]])
      # There are no other valid orders!

      assert Decoder.decode(DummySchema, encoded_asc) == decoded_asc
      assert Encoder.encode(decoded_asc) == encoded_asc

      assert Decoder.decode(DummySchema, encoded_desc) == decoded_desc
      assert Encoder.encode(decoded_desc) == encoded_desc
    end

    test "invalid direction raises an error" do
      encoded_invalid_direction = %{"sort" => %{"string_field" => %{"direction" => "invalid_direction"}}}
      encoded_invalid_direction_common_misspelling = %{"sort" => %{"string_field" => %{"direction" => "dsc"}}}

      assert_raise InvalidSortDirectionError, fn ->
        Decoder.decode(DummySchema, encoded_invalid_direction)
      end

      assert_raise InvalidSortDirectionError, fn ->
        Decoder.decode(DummySchema, encoded_invalid_direction_common_misspelling)
      end
    end
  end

  describe "pagination" do
  end

  describe "handling of invalid fields" do
    test "invalid fields in search" do
      encoded =
        %{"search" => %{
          "invalid_field" => %{
            "operator" => "contains",
            "value" => "x"}}}

      assert_raise InvalidFieldError, fn ->
        Decoder.decode(DummySchema, encoded)
      end
    end

    test "invalid fields in sort" do
      encoded =
        %{"sort" => %{
          "invalid_field" => "desc"}}

      assert_raise InvalidFieldError, fn ->
        Decoder.decode(DummySchema, encoded)
      end
    end
  end
end
