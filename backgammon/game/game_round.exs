Code.require_file("backgammon/domain/board.exs")
Code.require_file("backgammon/domain/dice.exs")
Code.require_file("backgammon/player/player.exs")
Code.require_file("backgammon/utils/validator.exs")
Code.require_file("backgammon/game/game_validator.exs")

defmodule GameRound do
  def start_round(player, opponent) do
    board = Board.create()
    white_pieces_player_move(player, opponent, board)
  end

  defp white_pieces_player_move(player, opponent, board) do
    Player.show_data(opponent)
    Board.show(board)
    Player.show_data(player)
    IO.write("\n")

    dice_rolled = dice_roll(player)
    {new_board, updated_player} = player_move(player, dice_rolled, board)
    black_pieces_player_move(updated_player, opponent, new_board)
  end

  defp black_pieces_player_move(player, opponent, board) do
    Player.show_data(opponent)
    Board.show(board)
    Player.show_data(player)
    IO.write("\n")

    dice_rolled = dice_roll(opponent)
    {new_board, updated_player} = player_move(opponent, dice_rolled, board)
    white_pieces_player_move(player, updated_player, new_board)
  end

  defp player_move(player, dice_rolled, board) do
    IO.puts("\nWhat would you like to do?")
    IO.puts("1. Move one checker #{Enum.at(dice_rolled, 0)} spaces and the other #{Enum.at(dice_rolled, 1)} spaces")
    IO.puts("2. Move one checker #{Enum.at(dice_rolled, 0) + Enum.at(dice_rolled, 1)} spaces")

    if player |> Player.get_hit_pieces > 0 do
      move_hit_pieces(player, dice_rolled, board)
    else
      get_choice(player, dice_rolled, board)
    end
  end

  defp move_hit_pieces(player, dice_rolled, board) do
    piece_colour = Player.get_piece_colour(player)
    {start_col, direction} = if piece_colour == "W", do: {0, 1}, else: {25, -1}

    # Attempt to move hit pieces using the dice rolls
    {updated_board, updated_player} =
      Enum.reduce(dice_rolled, {board, player}, fn dice_number, {current_board, current_player} ->
        new_col = start_col + direction * dice_number

        # Check if the new column is valid and the move is allowed
        if GameValidator.can_move?(current_board, piece_colour, start_col, new_col) do
          # Move the piece and update the board and player
          {updated_board, updated_player} = move_piece(current_player, dice_number, current_board, start_col)
          {updated_board, updated_player}
        else
          IO.puts("Cannot move to column #{new_col}. Skipping this move.")
          {current_board, current_player}
        end
      end)

    # If no moves were made, skip the turn
    if updated_board == board do
      IO.puts("No valid moves for hit pieces. Skipping turn.")
      {updated_board, updated_player}
    else
      {updated_board, updated_player}
    end
  end

  defp move_piece(player, dice_number, board, old_col \\ nil) do
    old_col = if is_nil(old_col), do: Validator.get_valid_integer("Column number of the moved piece: "), else: old_col

    if Validator.validate_interval(old_col, 1, 24) == false do
      move_piece_fail(player, dice_number, board, "invalid_space")
      {board, player}
    else
      old_row = GameValidator.get_highest_occupied_index(4, Board.get_col(board, 0, old_col))

      if is_nil(old_row) do
        IO.puts("Invalid move: No piece found in column #{old_col}.")
        move_piece_fail(player, dice_number, board, "empty_space")
        {board, player}
      else
        piece_colour = player |> Player.get_piece_colour() |> String.trim()
        opposite_colour = player |> Player.get_opposite_colour() |> String.trim()
        new_col = find_new_col(piece_colour, old_row, old_col, dice_number)

        if GameValidator.can_capture?(board, piece_colour, old_col, new_col) do
          captured_row = GameValidator.get_highest_occupied_index(4, Board.get_col(board, 0, new_col))
          board = Matrix.set(board, captured_row, new_col, "-")

          updated_player = player |> Player.increment_hit_pieces()
          updated_board = modify_board(old_row, old_col, new_col, dice_number, board)
          {updated_board, updated_player}
        else
          if GameValidator.can_move?(board, piece_colour, old_col, new_col) do
            updated_board = modify_board(old_row, old_col, new_col, dice_number, board)
            {updated_board, player}
          else
            cond do
              board |> Matrix.get(old_row, old_col) == opposite_colour ->
                move_piece_fail(player, dice_number, board, "wrong_colour")
                {board, player}

              true ->
                move_piece_fail(player, dice_number, board, "invalid_move")
                {board, player}
            end
          end
        end
      end
    end
  end

  defp modify_board(old_row, old_col, new_col, _dice_number, board) do
    piece_colour = Matrix.get(board, old_row, old_col)

    col_data = Board.get_col(board, 0, new_col)
    new_row = GameValidator.get_first_empty_from_bottom(4, col_data)

    if is_nil(new_row) do
      IO.puts("Invalid move: Column #{new_col} is full.")
      board
    else
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

  defp find_new_col(piece_colour, _current_row, current_col, dice_number) do
    cond do
      piece_colour == "W" -> current_col - dice_number
      piece_colour == "B" -> current_col + dice_number
      true -> current_col
    end
  end

  defp get_opposite_colour(piece_colour) do
    case piece_colour do
      "W" -> "B"
      "B" -> "W"
      _ -> "-"
    end
  end

  defp ai_move(_player, _opponent, _board) do
  end

  defp dice_roll(player) do
    dice1 = Dice.roll(6)
    dice2 = Dice.roll(6)

    IO.puts("#{Player.get_name(player)} rolled:")
    IO.puts("Dice 1: #{dice1}\nDice 2: #{dice2}")

    [dice1, dice2]
  end

  defp get_choice(player, dice_rolled, board) do
    choice = IO.gets("Choice: ") |> String.trim()

    case Integer.parse(choice) do
      {1, ""} ->
        {updated_board, updated_player} = move_piece(player, Enum.at(dice_rolled, 0), board)
        {final_board, final_player} = move_piece(updated_player, Enum.at(dice_rolled, 1), updated_board)
        {final_board, final_player}

      {2, ""} ->
        move_piece(player, Enum.at(dice_rolled, 0) + Enum.at(dice_rolled, 1), board)

      _ ->
        get_choice_fail(player, dice_rolled, board)
    end
  end

  defp get_choice_fail(player, dice_rolled, board) do
    IO.puts("Sorry for this primitive UI! Please choose a valid option (1 or 2)!")
    get_choice(player, dice_rolled, board)
  end

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
