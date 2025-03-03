Code.require_file("backgammon/domain/board.exs")
Code.require_file("backgammon/domain/dice.exs")
Code.require_file("backgammon/player/player.exs")

defmodule GameRound do
  def start_round(player, opponent) do
    board = Board.create()
    white_pieces_player_move(player, opponent, board)
  end

  defp white_pieces_player_move(player, opponent, board) do
    IO.puts(opponent |> Player.get_name)
    Board.show(board)
    IO.puts(player |> Player.get_name)
  end

  defp black_pieces_player_move(player, opponent, board) do
    IO.puts(player |> Player.get_name)
    Board.show_rotated(board)
    IO.puts(opponent |> Player.get_name)
  end

  defp ai_move(player, opponent, board) do

  end
end
