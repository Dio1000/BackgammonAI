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

end
