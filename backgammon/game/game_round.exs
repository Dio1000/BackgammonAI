Code.require_file("backgammon/domain/board.exs")
Code.require_file("backgammon/domain/dice.exs")
Code.require_file("backgammon/player/player.exs")

defmodule GameRound do
  def start_round(player, opponent) do
    board = Board.create()
    white_pieces_player_move(player, opponent, board)
  end

  defp white_pieces_player_move(player, opponent, board) do
    Player.show_data(opponent)
    Board.show_rotated(board)
    Player.show_data(player)
    IO.write("\n")

    move_number = dice_roll(player)

    #black_pieces_player_move(player, opponent, board)
  end

  defp black_pieces_player_move(player, opponent, board) do
    Player.show_data(player)
    Board.show(board)
    Player.show_data(opponent)
    IO.write("\n")

    move_number = dice_roll(player)

    white_pieces_player_move(player, opponent, board)
  end

  defp ai_move(player, opponent, board) do

  end

  defp dice_roll(player) do
    dice1 = Dice.roll(6)
    dice2 = Dice.roll(6)
    total = dice1 + dice2

    IO.puts("#{Player.get_name(player)} rolled:")
    IO.puts("Dice 1: #{dice1}")
    IO.puts("Dice 2: #{dice2}")
    IO.puts("Total: #{total}")

    total
  end
end
