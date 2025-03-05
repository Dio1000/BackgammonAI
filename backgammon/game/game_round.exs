Code.require_file("backgammon/domain/board.exs")
Code.require_file("backgammon/domain/dice.exs")
Code.require_file("backgammon/player/player.exs")

defmodule GameRound do

  # Starts a round of Backgammon, setups the board and allows the player with the
  # white pieces to play the first move.
  def start_round(player, opponent) do
    board = Board.create()
    white_pieces_player_move(player, opponent, board)
  end

  # Displays the board, data about the players and allows the white pieces player
  # to play their move.
  defp white_pieces_player_move(player, opponent, board) do
    Player.show_data(opponent)
    Board.show_rotated(board)
    Player.show_data(player)
    IO.write("\n")

    dice_rolled = dice_roll(player)

    #black_pieces_player_move(player, opponent, board)
  end

  # Displays the board, data about the players and allows the black pieces player
  # to play their move.
  defp black_pieces_player_move(player, opponent, board) do
    Player.show_data(player)
    Board.show(board)
    Player.show_data(opponent)
    IO.write("\n")

    dice_rolled = dice_roll(player)

    white_pieces_player_move(player, opponent, board)
  end

  # Allows the AI to check for the best move and play it.
  defp ai_move(player, opponent, board) do

  end

  # Auxiliary function to roll the dice and returns the values of the dice.
  defp dice_roll(player) do
    dice1 = Dice.roll(6)
    dice2 = Dice.roll(6)
    total = dice1 + dice2

    IO.puts("#{Player.get_name(player)} rolled:")
    IO.puts("Dice 1: #{dice1}")
    IO.puts("Dice 2: #{dice2}")
    IO.puts("Total: #{total}")

    [dice1 | dice2]
  end
end
