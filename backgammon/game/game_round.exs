Code.require_file("backgammon/domain/board.exs")
Code.require_file("backgammon/domain/dice.exs")
Code.require_file("backgammon/player/player.exs")
Code.require_file("backgammon/utils/validator.exs")
Code.require_file("backgammon/game/game_validator.exs")

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
    Board.show(board)
    Player.show_data(player)
    IO.write("\n")

    dice_rolled = dice_roll(player)
    new_board = player_move(player, dice_rolled, board)

    black_pieces_player_move(player, opponent, new_board)
  end

  # Displays the board, data about the players and allows the black pieces player
  # to play their move.
  defp black_pieces_player_move(player, opponent, board) do
    Player.show_data(opponent)
    Board.show(board)
    Player.show_data(player)
    IO.write("\n")

    dice_rolled = dice_roll(opponent)
    new_board = player_move(opponent, dice_rolled, board)

    white_pieces_player_move(player, opponent, new_board)
  end

  # Allows the player to make a move based on the numbers on their rolled dice.
  defp player_move(player, dice_rolled, board) do
    IO.puts("\nWhat would you like to do?")
    IO.puts("1. Move one checker #{Enum.at(dice_rolled, 0)} spaces and the other #{Enum.at(dice_rolled, 1)} spaces")
    IO.puts("2. Move one checker #{Enum.at(dice_rolled, 0) + Enum.at(dice_rolled, 1)} spaces")

    new_board = get_choice(player, dice_rolled, board)
    new_board
  end

  # Moves a piece on the board and returns a modified board.
  defp move_piece(player, dice_number, board) do
    old_col = Validator.get_valid_integer("Column number of the moved piece: ")

    if Validator.validate_interval(old_col, 1, 24) == false do
      move_piece_fail(player, dice_number, board, "invalid_space")
      board
    else
      old_row = GameValidator.get_top_index(board, 4, Board.get_col(board, 0, old_col))
      piece_colour = player |> Player.get_piece_colour() |> String.trim()
      opposite_colour = player |> Player.get_opposite_colour() |> String.trim()
      new_col = find_new_col(piece_colour, old_row, old_col, dice_number)

      valid_move =
        GameValidator.can_capture?(board, piece_colour, old_col, new_col) or
        GameValidator.can_move?(board, piece_colour, old_col, new_col)

      cond do
        valid_move ->
          modify_board(old_row, old_col, new_col, dice_number, board)

        board |> Matrix.get(old_row, old_col) == opposite_colour ->
          move_piece_fail(player, dice_number, board, "wrong_colour")
          board

        true ->
          move_piece_fail(player, dice_number, board, "empty_space")
          board
      end
    end
  end

  # Modifies the board to remove the piece on the given position and moves it
  # a given number of spaces based on its colour.
  defp modify_board(old_row, old_col, new_col, _dice_number, board) do
    piece_colour = Matrix.get(board, old_row, old_col)

    top_index = GameValidator.get_top_index(board, 4, Board.get_col(board, 0, new_col))
    new_row = if top_index == 4, do: 4, else: top_index + 1

    updated_board =
      board
      |> Matrix.set(old_row, old_col, "-")
      |> Matrix.set(new_row, new_col, piece_colour)

    updated_board
  end

  # Computes the column a piece would land based on a dice roll.
  defp find_new_col(piece_colour, _current_row, current_col, dice_number) do
    cond do
      piece_colour == "W" -> current_col - dice_number
      piece_colour == "B" -> current_col + dice_number
      true -> current_col
    end
  end

  # Auxiliary helper function to get the opposite of a colour.
  defp get_opposite_colour(piece_colour) do
    case piece_colour do
      "W" -> "B"
      "B" -> "W"
      _ -> "-"
    end
  end

  # Allows the AI to check for the best move and play it.
  defp ai_move(_player, _opponent, _board) do
  end

  # Auxiliary function to roll the dice and returns the values of the dice.
  defp dice_roll(player) do
    dice1 = Dice.roll(6)
    dice2 = Dice.roll(6)

    IO.puts("#{Player.get_name(player)} rolled:")
    IO.puts("Dice 1: #{dice1}\nDice 2: #{dice2}")

    [dice1, dice2]
  end

  # Auxiliary function which allows the user to pick from one of the 2 options.
  defp get_choice(player, dice_rolled, board) do
    choice = IO.gets("Choice: ") |> String.trim()

    case Integer.parse(choice) do
      {1, ""} ->
        board = move_piece(player, Enum.at(dice_rolled, 0), board)
        board = move_piece(player, Enum.at(dice_rolled, 1), board)
        board

      {2, ""} ->
        move_piece(player, Enum.at(dice_rolled, 0) + Enum.at(dice_rolled, 1), board)

      _ ->
        get_choice_fail(player, dice_rolled, board)
    end
  end

  # Auxiliary helper function to inform the user in the case they chose an invalid option.
  # Acts as a loop as the user is allowed to choose again after failing.
  defp get_choice_fail(player, dice_rolled, board) do
    IO.puts("Sorry for this primitive UI! Please choose a valid option (1 or 2)!")
    get_choice(player, dice_rolled, board)
  end

  # Auxiliary helper function to inform the user in the case the row and the column of
  # the piece they chose are invalid.
  defp move_piece_fail(player, dice_number, board, flag) do
    colour = Player.get_piece_colour(player)

    case flag do
      "wrong_colour" ->
        IO.puts("Wrong colour! Please choose a #{if colour == "W", do: "white", else: "black"} piece!")

      "empty_space" ->
        IO.puts("That space is empty! Choose a valid piece.")

      "invalid_space" ->
        IO.puts("That move is not valid!")

      "invalid_move" ->
        IO.puts("You can't move there!")
    end

    move_piece(player, dice_number, board)
  end
end
