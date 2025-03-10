Code.require_file("backgammon/domain/board.exs")

defmodule BoardUtils do

  # Creates a copy of a given board.
  def copy_board(board) do
    Enum.map(board, fn row -> Enum.map(row, fn cell -> cell end) end)
  end

  # Applies a move on the virtual board.
  def apply_move(board, {from_col, to_col}) do
    from_col_data = Board.get_col(board, 0, from_col)
    piece = Enum.at(from_col_data, 0)

    new_from_col_data = List.delete_at(from_col_data, 0)
    board = set_col(board, from_col, new_from_col_data)

    to_col_data = Board.get_col(board, 0, to_col)
    new_to_col_data = [piece | to_col_data]
    board = set_col(board, to_col, new_to_col_data)

    board
  end

  #Sets the column data for a specific column on the board.
  defp set_col(board, col, col_data) do
    Enum.with_index(board)
    |> Enum.map(fn {row, row_index} ->
      if row_index < length(col_data) do
        List.replace_at(row, col, Enum.at(col_data, row_index))
      else
        row
      end
    end)
  end
end
