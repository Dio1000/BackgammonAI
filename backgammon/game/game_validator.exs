defmodule GameValidator do
  # Checks if a player with a given piece colour can move any pieces.
  def can_move(piece_colour, board) do
    Enum.any?(for row <- 0..9, col <- 0..11, do: can_move_piece(piece_colour, row, col, 1, board))
  end

  # Checks if a piece can move based on the given dice roll and board state.
  def can_move_piece(piece_colour, row, col, dice_number, board) do
    case Matrix.get(board, row, col) do
      ^piece_colour -> check_valid_move(piece_colour, row, col, dice_number, board)
      _ -> false
    end
  end

  # Auxiliary helper function to check if a move is valid.
  defp check_valid_move(piece_colour, row, col, dice_number, board) do
    new_col = col + dice_number
    new_row = find_new_row(piece_colour, row, new_col, board)

    if new_col >= 12, do: false, else: can_land?(piece_colour, new_row, new_col, board)
  end

  # Determines where the piece should land.
  defp find_new_row(piece_colour, row, col, board) do
    if row < 5 do
      find_new_lower_row(piece_colour, 0, col, board)
    else
      find_new_upper_row(piece_colour, 9, col, board)
    end
  end

  # Checks if the piece can land in the new position (not occupied by 2+ opposing pieces).
  defp can_land?(piece_colour, row, col, board) do
    case Matrix.get(board, row, col) do
      "-" -> true
      ^piece_colour -> true
      _ -> count_pieces(board, row, col) < 2
    end
  end

  # Counts how many pieces are at a given position.
  defp count_pieces(board, row, col) do
    Enum.count(Enum.filter(0..9, fn r -> Matrix.get(board, r, col) != "-" end))
  end
end
