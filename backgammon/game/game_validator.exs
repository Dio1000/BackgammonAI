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

  def can_reenter?(board, piece_colour, new_col) do
    col = Board.get_col(board, 0, new_col)

    # Check if the column is open or contains the player's own pieces
    top_occupied_index = get_highest_occupied_index(4, col)

    if is_nil(top_occupied_index) do
      false
    else
      top_occupied_colour = Enum.at(col, top_occupied_index)
      top_occupied_colour == piece_colour
    end
  end

  # Counts the number of "W" and "B" pieces on the board
  def count_pieces(board) do
    Enum.reduce(board, %{"W" => 0, "B" => 0}, fn row, acc ->
      Enum.reduce(row, acc, fn cell, acc ->
        case cell do
          "W" -> Map.update!(acc, "W", &(&1 + 1))
          "B" -> Map.update!(acc, "B", &(&1 + 1))
          _ -> acc
        end
      end)
    end)
  end

  # Calculates the number of hit pieces for a player
  def calculate_hit_pieces(board, player) do
    piece_colour = Player.get_piece_colour(player) |> String.trim()
    max_pieces = 15

    piece_count = count_pieces(board)[piece_colour]
    max_pieces - piece_count
  end
end
