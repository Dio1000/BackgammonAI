Code.require_file("backgammon/player/player.exs")

defmodule PlayerBuilder do
  def build,
    do: %Player{}

  def default_build do
    player = PlayerBuilder.build()
    |> PlayerBuilder.set_name()
    |> PlayerBuilder.set_status()
    |> PlayerBuilder.set_pieces_white()
    |> PlayerBuilder.set_position_score()
    player
  end

  def set_name(player, name),
    do: %{player | name: name}

  def set_name(player),
    do: %{player | name: "AI"}

  def set_status(player, status),
    do: %{player | status: status}

  def set_status(player),
    do: %{player | status: "None"}

  def set_pieces_white(player),
    do: %{player | piece_colour: "White"}

  def set_pieces_black(player),
    do: %{player | piece_colour: "Black"}

  def set_position_score(player, position_score),
    do: %{player | position_score: position_score}

  def set_position_score(player),
    do: %{player | position_score: 0}
end
