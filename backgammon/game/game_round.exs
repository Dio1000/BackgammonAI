Code.require_file("backgammon/domain/board.exs")
Code.require_file("backgammon/domain/dice.exs")
Code.require_file("backgammon/player/player.exs")
Code.require_file("backgammon/utils/validator.exs")

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
    player_move(player, dice_rolled, board)

    black_pieces_player_move(player, opponent, board)
  end

  # Displays the board, data about the players and allows the black pieces player
  # to play their move.
  defp black_pieces_player_move(player, opponent, board) do
    Player.show_data(player)
    board = Matrix.rotate(board)

    Board.show(board)
    Player.show_data(opponent)
    IO.write("\n")

    dice_rolled = dice_roll(opponent)
    player_move(opponent, dice_rolled, board)

    board = Matrix.rotate(board)
    white_pieces_player_move(player, opponent, board)
  end

  # Allows the player to make a move based on the numbers on their rolled dice.
  defp player_move(player, dice_rolled, board) do
    IO.puts("\nWhat would you like to do?")
    IO.puts("1. Move one checker #{Enum.at(dice_rolled, 0)} spaces and the other #{Enum.at(dice_rolled, 1)} spaces")
    IO.puts("2. Move one checker #{Enum.at(dice_rolled, 0) + Enum.at(dice_rolled, 1)} spaces")

    get_choice(player, dice_rolled, board)
  end

  # Moves a piece on the board and returns a modified board.
  defp move_piece(player, dice_number, board) do
    old_row = Validator.get_valid_integer("Row of the moved piece: ")
    old_col = Validator.get_valid_integer("Column of the moved piece: ")

    if Validator.validate_interval(old_row, 0, 9) == false do
        move_piece_fail(player, dice_number, board, "invalid_space")
    end

    if Validator.validate_interval(old_col, 0, 11) == false do
        move_piece_fail(player, dice_number, board, "invalid_space")
    end

    piece_colour = player |> Player.get_piece_colour() |> String.trim()
    opposite_colour = player |> Player.get_opposite_colour() |> String.trim()

    case board |> Matrix.get(old_row, old_col) do
      ^piece_colour ->
        modify_board(old_row, old_col, dice_number, board)

      ^opposite_colour ->
        move_piece_fail(player, dice_number, board, "wrong_colour")

      _ ->
        move_piece_fail(player, dice_number, board, "empty_space")
    end
  end

  # Modifies the board to remove the piece on the given position and moves it
  # a given number of spaces based on its colour.
  defp modify_board(old_row, old_col, dice_number, board) do
    piece_colour = Matrix.get(board, old_row, old_col)
    board = Matrix.set(board, old_row, old_col, "-")

    new_col = find_new_col(piece_colour, old_row, old_col, dice_number)
    new_row =
      if old_row < 5 do
        find_new_lower_row(piece_colour, 0, new_col, board)
      else
        find_new_upper_row(piece_colour, 9, new_col, board)
      end

    IO.inspect([new_row, new_col, Matrix.get(board, old_row, old_col)])
    Matrix.set(board, new_row, new_col, piece_colour)
  end

  # Computes the column a piece would land based on a dice roll.
  defp find_new_col(piece_colour, current_row, current_col, dice_number) do
    cond do
      current_row >= 5 and piece_colour == "W" -> abs(current_col - dice_number)
      current_row >= 5 and piece_colour == "B" -> current_col + dice_number
      current_row < 5 and piece_colour == "W" -> current_col + dice_number
      current_row < 5 and piece_colour == "B" -> abs(current_col - dice_number)
      true -> current_col
    end
  end

  # Finds the lowest available row in the lower half of the board
  defp find_new_lower_row(piece_colour, row, col, board) do
    current_piece = Matrix.get(board, row, col)
    opposite_piece = get_opposite_colour(current_piece)

    cond do
      current_piece == piece_colour -> find_new_lower_row(piece_colour, row + 1, col, board)
      current_piece == opposite_piece -> row
      current_piece == "-" -> row
      true -> row
    end
  end

  # Finds the highest available row in the upper half of the board
  defp find_new_upper_row(piece_colour, row, col, board) do
    current_piece = Matrix.get(board, row, col)
    opposite_piece = get_opposite_colour(current_piece)

    cond do
      current_piece == piece_colour -> find_new_upper_row(piece_colour, row - 1, col, board)
      current_piece == opposite_piece -> row
      current_piece == "-" -> row
      true -> row
    end
  end

  # Auxiliary helper function to get the opposite of a colour.
  defp get_opposite_colour(piece_colour) do
    case piece_colour do
      "W" ->
        "B"
      "B" ->
        "W"
      "-" ->
        "-"
    end
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

    [dice1, dice2]
  end

  # Auxliary function which allows the user to pick from one of the 2 options.
  defp get_choice(player, dice_rolled, board) do
    choice = IO.gets("Choice: ") |> String.trim()

    case Integer.parse(choice) do
      {1, ""} ->
        move_piece(player, Enum.at(dice_rolled, 0), board)
        move_piece(player, Enum.at(dice_rolled, 1), board)

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
        if colour == "W" do
          IO.puts("Wrong colour! Please choose a white piece!")
        else
          IO.puts("Wrong colour! Please choose a black piece!")
        end

      "empty_space" ->
        if colour == "W" do
          IO.puts("Wrong colour! Please choose a white piece!")
        else
          IO.puts("Wrong colour! Please choose a black piece!")
        end

      "invalid_space" ->
        IO.puts("The matrix is 10x12, indexing starts at 0!")
    end

    move_piece(player, dice_number, board)
  end

end
