defmodule GameValidator do
  # Finds the first empty space from the bottom of a column.
  def get_first_empty_from_bottom(_max_height, col_data) do
    col_data
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.find_value(fn {cell, index} -> if cell == "-", do: 4 - index end)
  end

  # Finds the highest occupied position in a column.
  def get_highest_occupied_index(_max_height, col_data) do
    col_data
    |> Enum.with_index()
    |> Enum.find_value(fn {cell, index} -> if cell != "-", do: index end)
  end

  # Finds the index of the first empty space in a column.
  def get_top_index(max_height, col_data) when is_list(col_data) do
    col_data
    |> Enum.with_index()
    |> Enum.find_value(fn {cell, index} -> if cell == "-", do: index end)
  end

  def get_top_index(_max_height, _col_data), do: nil

  # Calculates the number of occupied spaces in a column.
  def get_occupied_places(board, index, col) do
    cond do
      Enum.at(col, index) in ["W", "B"] -> 1 + get_occupied_places(board, index - 1, col)
      index == 0 -> 0
      true -> get_occupied_places(board, index - 1, col)
    end
  end

  # Checks if a piece can move to the specified new column.
  def can_move?(board, piece_colour, _old_col, new_col) do
    col = Board.get_col(board, 0, new_col)

    top_occupied_index = get_highest_occupied_index(4, col)

    if is_nil(top_occupied_index) do
      true
    else
      top_occupied_colour = Enum.at(col, top_occupied_index)
      top_occupied_colour == piece_colour
    end
  end

  # Checks if a piece can capture another piece in the specified new column.
  def can_capture?(board, piece_colour, _old_col, new_col) do
    col = Board.get_col(board, 0, new_col)

    top_occupied_index = get_highest_occupied_index(4, col)

    if is_nil(top_occupied_index) do
      false
    else
      top_occupied_colour = Enum.at(col, top_occupied_index)
      top_occupied_colour != piece_colour and get_occupied_places(board, 4, col) == 1
    end
  end
end
