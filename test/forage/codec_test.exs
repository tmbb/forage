# Instead of testing encoding and decoding separately, we test them together.
# If `Decoder.decode(a) == b`, then it is always true that `Encoder.encode(b) == a`.
# We take advantage of this to write (slightly) less boilerplate and always test
# encoding and decoding at the same time
defmodule Forage.CodecTest do
  use ExUnit.Case, async: true
  alias Forage.Codec.Encoder
  alias Forage.Codec.Decoder
  alias Forage.ForagePlan
  alias Forage.ForagePlan.Filter

  # Exceptions
  # alias Forage.Codec.Exceptions.InvalidAssocError
  # alias Forage.Codec.Exceptions.InvalidFieldError
  alias Forage.Codec.Exceptions.InvalidSortDirectionError
  # Testing hepers
  alias Forage.Test.Support.PrimarySchema

  doctest Forage.Codec.Encoder

  # This module is naturally divided into 5 sections:
  # - Filter (encoding and decoding of filters)
  # - Sort (encoding and decoding of sort fields)
  # - Pagination (encoding and decoding of pagination data)
  # - Integration ("real-life"-like inputs)
  # - Invalid Field errors (deals with identifying invalid fields)

  describe "filter" do
    test "single filter" do
      encoded = %{
        "_filter" => %{"string_field" => %{"op" => "contains", "val" => "x"}},
        "_sort" => %{}
      }

      decoded = %ForagePlan{
        filter: [
          %Filter{field: {:simple, :string_field}, operator: "contains", value: "x"}
        ]
      }

      assert Encoder.encode(decoded) == encoded
      assert Decoder.decode(encoded, PrimarySchema) == decoded
    end

    test "multiple filters" do
      encoded = %{
        "_filter" => %{
          "string_field" => %{"op" => "contains", "val" => "x"},
          "integer_field" => %{"op" => "equal_to", "val" => "2"}
        },
        "_sort" => %{}
      }

      decoded = %ForagePlan{
        filter: [
          %Filter{field: {:simple, :integer_field}, operator: "equal_to", value: "2"},
          %Filter{field: {:simple, :string_field}, operator: "contains", value: "x"}
        ]
      }

      assert Encoder.encode(decoded) == encoded
      assert Decoder.decode(encoded, PrimarySchema) == decoded
    end

    test "association" do
      encoded = %{
        "_filter" => %{"owner.remote_string_field" => %{"op" => "contains", "val" => "x"}},
        "_sort" => %{}
      }

      decoded = %ForagePlan{
        filter: [
          %Forage.ForagePlan.Filter{
            field: {:assoc, {Forage.Test.Support.RemoteSchema, :owner, :remote_string_field}},
            operator: "contains",
            value: "x"
          }
        ]
      }

      assert Decoder.decode(encoded, PrimarySchema) == decoded
      assert Encoder.encode(decoded) == encoded
    end

    test "association + simple field" do
      encoded = %{
        "_filter" => %{
          "string_field" => %{"op" => "contains", "val" => "x"},
          "owner.remote_string_field" => %{"op" => "contains", "val" => "x"}
        },
        "_sort" => %{}
      }

      decoded = %ForagePlan{
        filter: [
          %Forage.ForagePlan.Filter{field: {:assoc, {Forage.Test.Support.RemoteSchema, :owner, :remote_string_field}}, operator: "contains", value: "x"},
          %Forage.ForagePlan.Filter{field: {:simple, :string_field}, operator: "contains", value: "x"}
        ]
      }

      # TODO: test the query somehow agains a real DB
      {_plan, _query} = Forage.QueryBuilder.build_plan_and_query(encoded, PrimarySchema)

      assert Decoder.decode(encoded, PrimarySchema) == decoded
      assert Encoder.encode(decoded) == encoded
    end

    test "multiple decoding runs preserve the order of the filters" do
      # Search filters are converted into keyword lists.
      # Those keyword lists must be ordered so that the decoder is referentially transparent.
      encoded = %{
        "_filter" => %{
          "string_field" => %{"op" => "contains", "val" => "x"},
          "integer_field" => %{"op" => "equal_to", "val" => "2"}
        }
      }

      decoded = %ForagePlan{
        filter: [
          %Forage.ForagePlan.Filter{
            field: {:simple, :integer_field},
            operator: "equal_to",
            value: "2"
          },
          %Forage.ForagePlan.Filter{
            field: {:simple, :string_field},
            operator: "contains",
            value: "x"
          }
        ]
      }

      decoded_wrong_order = %ForagePlan{
        filter: [
          %Forage.ForagePlan.Filter{
            field: {:simple, :string_field},
            operator: "contains",
            value: "x"
          },
          %Forage.ForagePlan.Filter{
            field: {:simple, :integer_field},
            operator: "equal_to",
            value: "2"
          }
        ]
      }

      for _ <- 1..100 do
        assert Decoder.decode(encoded, PrimarySchema) == decoded
        # Completely unnecessary but self-documenting
        assert Decoder.decode(encoded, PrimarySchema) != decoded_wrong_order
      end
    end
  end

  describe "sort" do
    test "single sort field" do
      # Ascending order
      encoded_asc = %{"_sort" => %{"string_field" => %{"direction" => "asc"}}, "_filter" => %{}}
      decoded_asc = %ForagePlan{sort: [%Forage.ForagePlan.Sort{direction: :asc, field: :string_field}]}
      # Descending order
      encoded_desc = %{"_sort" => %{"string_field" => %{"direction" => "desc"}}, "_filter" => %{}}
      decoded_desc = %ForagePlan{sort: [%Forage.ForagePlan.Sort{direction: :desc, field: :string_field}]}
      # There are no other valid orders!

      assert Decoder.decode(encoded_asc, PrimarySchema) == decoded_asc
      assert Encoder.encode(decoded_asc) == encoded_asc

      assert Decoder.decode(encoded_desc, PrimarySchema) == decoded_desc
      assert Encoder.encode(decoded_desc) == encoded_desc
    end

    test "invalid direction raises an error" do
      encoded_invalid_direction = %{
        "_sort" => %{"string_field" => %{"direction" => "invalid_direction"}}
      }

      encoded_invalid_direction_common_misspelling = %{
        "_sort" => %{"string_field" => %{"direction" => "dsc"}}
      }

      assert_raise InvalidSortDirectionError, fn ->
        Decoder.decode(encoded_invalid_direction, PrimarySchema)
      end

      assert_raise InvalidSortDirectionError, fn ->
        Decoder.decode(encoded_invalid_direction_common_misspelling, PrimarySchema)
      end
    end
  end

  # Still empty
  describe "pagination" do
  end
end
