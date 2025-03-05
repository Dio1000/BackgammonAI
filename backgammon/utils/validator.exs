defmodule Validator do

  # Helper function to get a valid integer from the user
  def get_valid_integer(prompt) do
    case IO.gets(prompt) |> String.trim() |> Integer.parse() do
      {num, ""} ->
        num
      _ ->
        IO.puts("Invalid integer!")
        get_valid_integer(prompt)
    end
  end
end
