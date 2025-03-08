Code.require_file("backgammon/domain/board.exs")
Code.require_file("backgammon/domain/dice.exs")
Code.require_file("backgammon/player/player.exs")
Code.require_file("backgammon/utils/validator.exs")
Code.require_file("backgammon/game/game_validator.exs")

defmodule GameRound do
  # This module handles the logic for a single round of Backgammon, including player moves, dice rolls, and board updates.

  # Starts a new round of Backgammon, initializes the board, and begins the game with the white pieces player.
  def start_round(player, opponent) do
    board = Board.create()
    white_pieces_player_move(player, opponent, board)
  end

  # Handles the white pieces player's move, displays the board and player data, and rolls the dice.
  defp white_pieces_player_move(player, opponent, board) do
    Player.show_data(opponent)
    Board.show(board)
    Player.show_data(player)
    IO.write("\n")

    dice_rolled = dice_roll(player)
    {new_board, updated_player, updated_opponent} = player_move(player, dice_rolled, board, opponent)
    black_pieces_player_move(updated_player, updated_opponent, new_board)
  end

  # Handles the black pieces player's move, displays the board and player data, and rolls the dice.
  defp black_pieces_player_move(player, opponent, board) do
    Player.show_data(opponent)
    Board.show(board)
    Player.show_data(player)
    IO.write("\n")

    dice_rolled = dice_roll(opponent)
    {new_board, updated_player, updated_opponent} = player_move(opponent, dice_rolled, board, player)
    white_pieces_player_move(updated_player, updated_opponent, new_board)
  end

  # Prompts the player to choose a move based on the dice rolls and handles the move logic.
  defp player_move(player, dice_rolled, board, opponent) do
    IO.puts("\nWhat would you like to do?")
    IO.puts("1. Move one checker #{Enum.at(dice_rolled, 0)} spaces and the other #{Enum.at(dice_rolled, 1)} spaces")
    IO.puts("2. Move one checker #{Enum.at(dice_rolled, 0) + Enum.at(dice_rolled, 1)} spaces")

    if player |> Player.get_hit_pieces > 0 do
      move_hit_pieces(player, dice_rolled, board, opponent)
    else
      get_choice(player, dice_rolled, board, opponent)
    end
  end

  # Handles the movement of hit pieces for a player based on the dice rolls.
  defp move_hit_pieces(player, dice_rolled, board, opponent) do
    piece_colour = Player.get_piece_colour(player)
    {start_col, direction} = if piece_colour == "W", do: {0, 1}, else: {25, -1}

    {updated_board, updated_player, updated_opponent} =
      Enum.reduce(dice_rolled, {board, player, opponent}, fn dice_number, {current_board, current_player, current_opponent} ->
        new_col = start_col + direction * dice_number

        if GameValidator.can_move?(current_board, piece_colour, start_col, new_col) do
          move_piece(current_player, dice_number, current_board, current_opponent, start_col)
        else
          {current_board, current_player, current_opponent}
        end
      end)

    if updated_board == board do
      {updated_board, updated_player, updated_opponent}
    else
      {updated_board, updated_player, updated_opponent}
    end
  end

  # Moves a piece on the board based on the dice roll and updates the player and opponent states.
  defp move_piece(player, dice_number, board, opponent, old_col \\ nil) do
    old_col = if is_nil(old_col), do: Validator.get_valid_integer("Column number of the moved piece: "), else: old_col

    if Validator.validate_interval(old_col, 1, 24) == false do
      move_piece_fail(player, dice_number, board, "invalid_space")
      {board, player, opponent}
    else
      old_row = GameValidator.get_highest_occupied_index(4, Board.get_col(board, 0, old_col))

      if is_nil(old_row) do
        move_piece_fail(player, dice_number, board, "empty_space")
        {board, player, opponent}
      else
        piece_colour = player |> Player.get_piece_colour() |> String.trim()
        opposite_colour = player |> Player.get_opposite_colour() |> String.trim()
        new_col = find_new_col(piece_colour, old_row, old_col, dice_number)

        if GameValidator.can_capture?(board, piece_colour, old_col, new_col) do
          captured_row = GameValidator.get_highest_occupied_index(4, Board.get_col(board, 0, new_col))
          board = Matrix.set(board, captured_row, new_col, "-")

          opponent_hit_pieces = GameValidator.calculate_hit_pieces(board, opponent)
          updated_opponent = %{opponent | hit_pieces: opponent_hit_pieces}

          updated_board = modify_board(old_row, old_col, new_col, dice_number, board)
          {updated_board, player, updated_opponent}
        else
          if GameValidator.can_move?(board, piece_colour, old_col, new_col) do
            updated_board = modify_board(old_row, old_col, new_col, dice_number, board)
            {updated_board, player, opponent}
          else
            cond do
              board |> Matrix.get(old_row, old_col) == opposite_colour ->
                move_piece_fail(player, dice_number, board, "wrong_colour")
                {board, player, opponent}

              true ->
                move_piece_fail(player, dice_number, board, "invalid_move")
                {board, player, opponent}
            end
          end
        end
      end
    end
  end

  # Modifies the board by moving a piece from the old position to the new position.
  defp modify_board(old_row, old_col, new_col, _dice_number, board) do
    piece_colour = Matrix.get(board, old_row, old_col)

    col_data = Board.get_col(board, 0, new_col)
    new_row = GameValidator.get_first_empty_from_bottom(4, col_data)

    if is_nil(new_row) do
      board
    else
      if GameValidator.can_move?(board, piece_colour, old_col, new_col) do
        board
        |> Matrix.set(old_row, old_col, "-")
        |> Matrix.set(new_row, new_col, piece_colour)
      else
        board
      end
    end
  end

  # Calculates the new column for a piece based on its current column and the dice roll.
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

  # Rolls the dice for a player and returns the results.
  defp dice_roll(player) do
    dice1 = Dice.roll(6)
    dice2 = Dice.roll(6)
    [dice1, dice2]
  end

  # Prompts the player to choose a move option and handles the choice.
  defp get_choice(player, dice_rolled, board, opponent) do
    choice = IO.gets("Choice: ") |> String.trim()

    case Integer.parse(choice) do
      {1, ""} ->
        {updated_board, updated_player, updated_opponent} = move_piece(player, Enum.at(dice_rolled, 0), board, opponent)
        {final_board, final_player, final_opponent} = move_piece(updated_player, Enum.at(dice_rolled, 1), updated_board, updated_opponent)
        {final_board, final_player, final_opponent}

      {2, ""} ->
        move_piece(player, Enum.at(dice_rolled, 0) + Enum.at(dice_rolled, 1), board, opponent)

      _ ->
        get_choice_fail(player, dice_rolled, board, opponent)
    end
  end

  # Handles invalid choice input and prompts the player to choose again.
  defp get_choice_fail(player, dice_rolled, board, opponent) do
    IO.puts("Sorry for this primitive UI! Please choose a valid option (1 or 2)!")
    get_choice(player, dice_rolled, board, opponent)
  end

  # Handles move failures and provides feedback to the player.
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

    {board, player}
  end
end
