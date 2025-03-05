Code.require_file("../utils/matrix.exs", __DIR__)
Code.require_file("dice.exs", __DIR__)

defmodule Board do

  # Creates and sets up the pieces for a new Backgammon board.
  def create() do
    Matrix.new(10, 12, "-")
    |> Matrix.set(0, 4, "W") |> Matrix.set(1, 4, "W") |> Matrix.set(2, 4, "W")
    |> Matrix.set(0, 6, "W") |> Matrix.set(1, 6, "W") |> Matrix.set(2, 6, "W") |> Matrix.set(3, 6, "W") |> Matrix.set(4, 6, "W")
    |> Matrix.set(0, 0, "B") |> Matrix.set(1, 0, "B") |> Matrix.set(2, 0, "B") |> Matrix.set(3, 0, "B") |> Matrix.set(4, 0, "B")
    |> Matrix.set(0, 11, "B") |> Matrix.set(1, 11, "B")

    |> Matrix.set(9, 4, "B") |> Matrix.set(8, 4, "B") |> Matrix.set(7, 4, "B")
    |> Matrix.set(9, 6, "B") |> Matrix.set(8, 6, "B") |> Matrix.set(7, 6, "B") |> Matrix.set(6, 6, "B") |> Matrix.set(5, 6, "B")
    |> Matrix.set(9, 0, "W") |> Matrix.set(8, 0, "W") |> Matrix.set(7, 0, "W") |> Matrix.set(6, 0, "W") |> Matrix.set(5, 0, "W")
    |> Matrix.set(9, 11, "W") |> Matrix.set(8, 11, "W")
  end

  # Displays the board in a formatted way.
  def show(board) do
    IO.puts("\n==============================================\n")

    formatted_board =
      board
      |> Enum.with_index()
      |> Enum.map(fn {row, index} ->
        row_string = format_row(row)

        separator =
          cond do
            index == 4 -> "\n=============================================="
            index < 9 -> "\n----------------------------------------------"
            true -> ""
          end

        row_string <> separator
      end)
      |> Enum.join("\n")

    IO.puts(formatted_board)
    IO.puts("\n============= BACKGAMMON BOARD ===============\n")
  end

  # Displays the rotated board (180 degrees to the right) in a formatted way.
  def show_rotated(board) do
    IO.puts("\n============= BACKGAMMON BOARD ===============\n")

    rotated_board = board |> Enum.reverse()

    formatted_board =
      rotated_board
      |> Enum.with_index()
      |> Enum.map(fn {row, index} ->
        row_string = format_row(row)

        separator =
          cond do
            index == 4 -> "\n=============================================="
            index < 9 -> "\n----------------------------------------------"
            true -> ""
          end

        row_string <> separator
      end)
      |> Enum.join("\n")

    IO.puts(formatted_board)
    IO.puts("\n==============================================\n")
  end

  # Auxiliary function to format the middle of the rows and columns in order to
  # differentiate between the 4 parts of a Backgammon board.
  defp format_row(row) do
    {left, right} = Enum.split(row, div(length(row), 2))
    Enum.join(left, " | ") <> " || " <> Enum.join(right, " | ")
  end
end
