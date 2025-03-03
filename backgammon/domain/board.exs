Code.require_file("../utils/matrix.exs", __DIR__)
Code.require_file("dice.exs", __DIR__)

defmodule Board do
  def create() do
    Matrix.new(10, 12, "N")
    |> Matrix.set()
  end

  def show(board) do
    IO.puts("\n============= BACKGAMMON BOARD ===============\n")

    formatted_board =
      board
      |> Enum.map(&Enum.join(&1, " | "))
      |> Enum.join("\n----------------------------------------------\n")

    IO.puts(formatted_board)
    IO.puts("\n==============================================\n")
  end

  def show_rotated(board) do
    IO.puts("\n==============================================\n")

    rotated_board =
      board
      |> Enum.reverse()
      |> Enum.map(&Enum.reverse(&1))

    formatted_board =
      rotated_board
      |> Enum.map(&Enum.join(&1, " | "))
      |> Enum.join("\n----------------------------------------------\n")

    IO.puts(formatted_board)
    IO.puts("\n============= BACKGAMMON BOARD ===============\n")
  end
end
