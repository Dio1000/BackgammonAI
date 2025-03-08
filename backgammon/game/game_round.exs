Code.require_file("backgammon/domain/board.exs")
Code.require_file("backgammon/domain/dice.exs")
Code.require_file("backgammon/player/player.exs")
Code.require_file("backgammon/utils/validator.exs")
Code.require_file("backgammon/game/game_validator.exs")

defmodule GameRound do
  # Starts a round of Backgammon, sets up the board, and allows the player with the white pieces to play the first move.
  def start_round(player, opponent) do
    board = Board.create()
    white_pieces_player_move(player, opponent, board)
  end

  # Displays the board, player data, and allows the white pieces player to make a move.
  defp white_pieces_player_move(player, opponent, board) do
    Player.show_data(opponent)
    Board.show(board)
    Player.show_data(player)
    IO.write("\n")

    dice_rolled = dice_roll(player)
    new_board = player_move(player, dice_rolled, board)

    black_pieces_player_move(player, opponent, new_board)
  end

  # Displays the board, player data, and allows the black pieces player to make a move.
  defp black_pieces_player_move(player, opponent, board) do
    Player.show_data(opponent)
    Board.show(board)
    Player.show_data(player)
    IO.write("\n")

    dice_rolled = dice_roll(opponent)
    new_board = player_move(opponent, dice_rolled, board)

    white_pieces_player_move(player, opponent, new_board)
  end

  # Allows the player to make a move based on the numbers rolled on the dice.
  defp player_move(player, dice_rolled, board) do
    IO.puts("\nWhat would you like to do?")
    IO.puts("1. Move one checker #{Enum.at(dice_rolled, 0)} spaces and the other #{Enum.at(dice_rolled, 1)} spaces")
    IO.puts("2. Move one checker #{Enum.at(dice_rolled, 0) + Enum.at(dice_rolled, 1)} spaces")

    get_choice(player, dice_rolled, board)
  end

  # Moves a piece on the board and returns the modified board.
  defp move_piece(player, dice_number, board) do
    old_col = Validator.get_valid_integer("Column number of the moved piece: ")

    if Validator.validate_interval(old_col, 1, 24) == false do
      move_piece_fail(player, dice_number, board, "invalid_space")
      board
    else
      old_row = GameValidator.get_highest_occupied_index(4, Board.get_col(board, 0, old_col))

      if is_nil(old_row) do
        IO.puts("Invalid move: No piece found in column #{old_col}.")
        move_piece_fail(player, dice_number, board, "empty_space")
        board
      else
        piece_colour = player |> Player.get_piece_colour() |> String.trim()
        opposite_colour = player |> Player.get_opposite_colour() |> String.trim()
        new_col = find_new_col(piece_colour, old_row, old_col, dice_number)

        if GameValidator.can_capture?(board, piece_colour, old_col, new_col) do

          captured_row = GameValidator.get_highest_occupied_index(4, Board.get_col(board, 0, new_col))
          board = Matrix.set(board, captured_row, new_col, "-")

          # TODO: Add logic to handle the captured piece.
          modify_board(old_row, old_col, new_col, dice_number, board)
        else
          if GameValidator.can_move?(board, piece_colour, old_col, new_col) do
            modify_board(old_row, old_col, new_col, dice_number, board)
          else
            cond do
              board |> Matrix.get(old_row, old_col) == opposite_colour ->
                move_piece_fail(player, dice_number, board, "wrong_colour")
                board

              true ->
                move_piece_fail(player, dice_number, board, "invalid_move")
                board
            end
          end
        end
      end
    end
  end

  # Modifies the board to remove the piece from the old position and place it in the new position.
  defp modify_board(old_row, old_col, new_col, _dice_number, board) do
    piece_colour = Matrix.get(board, old_row, old_col)

    col_data = Board.get_col(board, 0, new_col)
    new_row = GameValidator.get_first_empty_from_bottom(4, col_data)

    if is_nil(new_row) do
      IO.puts("Invalid move: Column #{new_col} is full.")
      board
    else
      # Ensure the move is valid before proceeding
      if GameValidator.can_move?(board, piece_colour, old_col, new_col) do
        updated_board =
          board
          |> Matrix.set(old_row, old_col, "-")
          |> Matrix.set(new_row, new_col, piece_colour)

        updated_board
      else
        IO.puts("Invalid move: Cannot stack on opposite-coloured pieces.")
        board
      end
    end
  end

  # Computes the new column based on the piece colour and dice roll.
  defp find_new_col(piece_colour, _current_row, current_col, dice_number) do
    cond do
      piece_colour == "W" -> current_col - dice_number
      piece_colour == "B" -> current_col + dice_number
      true -> current_col
    end
  end

  # Returns the opposite colour of the given piece colour.
  defp get_opposite_colour(piece_colour) do
    case piece_colour do
      "W" -> "B"
      "B" -> "W"
      _ -> "-"
    end
  end

  # Placeholder for AI move logic.
  defp ai_move(_player, _opponent, _board) do
  end

  # Rolls the dice and returns the values.
  defp dice_roll(player) do
    dice1 = Dice.roll(6)
    dice2 = Dice.roll(6)

    IO.puts("#{Player.get_name(player)} rolled:")
    IO.puts("Dice 1: #{dice1}\nDice 2: #{dice2}")

    [dice1, dice2]
  end

  # Allows the user to choose between two move options.
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

  # Handles invalid choice input and prompts the user to choose again.
  defp get_choice_fail(player, dice_rolled, board) do
    IO.puts("Sorry for this primitive UI! Please choose a valid option (1 or 2)!")
    get_choice(player, dice_rolled, board)
  end

  # Handles move failures and provides feedback to the user.
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
