defmodule Player do
  defstruct name: nil, status: nil, piece_colour: nil, position_score: 0

  def get_name(player) do
    Map.get(player |> Map.from_struct, :name)
  end

  def get_status(player) do
    Map.get(player |> Map.from_struct, :status)
  end

  def get_piece_colour(player) do
    Map.get(player |> Map.from_struct, :piece_colour)
  end

  def get_position_score(player) do
    Map.get(player |> Map.from_struct, :position_score)
  end
end
