Code.require_file("backgammon/domain/board.exs")

defmodule GameValidator do

  # Gets the index of the first element of a column that is not empty.
  # Note: The default value for the index should be 4.
  def get_top_index(_board, _max_height, col_data) do
    col_data
    |> Enum.with_index()
    |> Enum.find_value(fn {cell, index} -> if cell != "-", do: index end)
    |> case do
      nil -> 4  # If the column is empty, return the bottom row
      index -> index
    end
  end

  # Gets the number of occupied places of a column.
  # Note: The default value for the index should be 4.
  def get_occupied_places(board, index, col) do
    cond do
      Enum.at(col, index) in ["W", "B"] -> 1 + get_occupied_places(board, index - 1, col)
      index == 0 -> 0
      true -> get_occupied_places(board, index - 1, col)
    end
  end

  # Checks if a piece can capture another piece.
  def can_capture?(board, piece_colour, old_col, new_col) do
    col = Board.get_col(board, 0, new_col)
    occupied_places = get_occupied_places(board, 4, col)

    place_colour = Enum.at(col, 0)

    if place_colour == "-" do
      false
    else
      case occupied_places do
        1 -> piece_colour != place_colour
        _ -> false
      end
    end
  end

  # Checks if a piece can move to a specified new column.
  def can_move?(board, piece_colour, _old_col, new_col) do
    col = Board.get_col(board, 0, new_col)
    occupied_places = get_occupied_places(board, 4, col)

    if occupied_places == 5 do
      false  # Column is full
    else
      top_index = get_top_index(board, 4, col)
      place_colour = Enum.at(col, top_index)

      # A piece can move if the destination is empty or has a friendly piece
      place_colour == "-" or place_colour == piece_colour
    end
  end
end
