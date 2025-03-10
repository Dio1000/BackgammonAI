Code.require_file("backgammon/engine/game_state.exs")
Code.require_file("backgammon/player/player.exs")
Code.require_file("backgammon/game/game_validator.exs")
Code.require_file("backgammon/engine/engine_utils.exs")
Code.require_file("backgammon/engine/move_generator.exs")

defmodule GameEngine do

  # Calculates the score of a given position in a game of Backgammon for a given
  # piece colour.
  def calculate_position_score(player, board) do
    homebase_score = GameEngineUtils.compute_homebase_score(player, board)
    vulnerable_score = GameEngineUtils.compute_vulnerable_pieces_score(player, board)
    blocking_score = GameEngineUtils.compute_blocking_positions_score(player, board)
    pip_score = GameEngineUtils.compute_pip_count_score(player, board)
    hit_and_beared_score = GameEngineUtils.compute_hit_and_beared_off_pieces_score(player, board)

    total_score = homebase_score + vulnerable_score + blocking_score + pip_score + hit_and_beared_score
  end

  @max_depth 3
  @positive_infinity 1_000_000
  @negative_infinity -1_000_000

  # Chooses and returns the best move that can be played in a given Game State.
  def choose_best_move(game_state) do
    valid_moves = MoveGenerator.generate_moves(game_state)

    {best_move, _best_score} = Enum.reduce(valid_moves, {nil, @negative_infinity}, fn move, {best_move, best_score} ->
      new_board = BoardUtils.apply_move(game_state.board, move)
      new_game_state = %GameState{
        board: new_board,
        player: game_state.opponent,
        opponent: game_state.player,
        dice_roll: game_state.dice_roll,
        depth: @max_depth
      }

      score = alphabeta(new_game_state, @max_depth, @negative_infinity, @positive_infinity, false)

      if score > best_score do
        {move, score}
      else
        {best_move, best_score}
      end
    end)

    best_move
  end

  # Uses the AlphaBeta algorithm to choose which path is best to take in a given game state.
  # The other paths are pruned, meaning that the algorithm will not check them, seeing as their score
  # is smaller than the others.
  def alphabeta(game_state, depth, alpha, beta, maximizing_player) do
    if depth == 0 or game_over?(game_state) do
      GameEngine.calculate_position_score(game_state.player, game_state.board)
    else
      if maximizing_player do
        value = @negative_infinity
        valid_moves = MoveGenerator.generate_moves(game_state)

        Enum.reduce(valid_moves, value, fn move, acc ->
          new_board = BoardUtils.apply_move(game_state.board, move)
          new_game_state = %GameState{
            board: new_board,
            player: game_state.opponent,
            opponent: game_state.player,
            dice_roll: game_state.dice_roll,
            depth: depth - 1
          }

          new_value = alphabeta(new_game_state, depth - 1, alpha, beta, false)
          value = max(value, new_value)
          alpha = max(alpha, value)

          if beta <= alpha do
            acc
          else
            value
          end
        end)
      else
        value = @positive_infinity
        valid_moves = MoveGenerator.generate_moves(game_state)

        Enum.reduce(valid_moves, value, fn move, acc ->
          new_board = BoardUtils.apply_move(game_state.board, move)
          new_game_state = %GameState{
            board: new_board,
            player: game_state.opponent,
            opponent: game_state.player,
            dice_roll: game_state.dice_roll,
            depth: depth - 1
          }

          new_value = alphabeta(new_game_state, depth - 1, alpha, beta, true)
          value = min(value, new_value)
          beta = min(beta, value)

          if beta <= alpha do
            acc
          else
            value
          end
        end)
      end
    end
  end

  defp game_over?(game_state) do
    false  # Placeholder
  end

end
