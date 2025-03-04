defmodule Player do
  defstruct name: nil, status: nil, piece_colour: nil, position_score: 0,
  hit_pieces: 0, beared_pieces: 0

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

  def get_hit_pieces(player) do
    Map.get(player |> Map.from_struct, :hit_pieces)
  end

  def get_beared_pieces(player) do
    Map.get(player |> Map.from_struct, :beared_pieces)
  end

  def get_player1(filename) do
    case File.read(filename) do
      {:ok, content} ->
        content |> String.split("\n") |> Enum.at(0)
        |> String.split(":") |> Enum.at(1) |> String.trim()

      {:error, reason} ->
        IO.puts("Error reading file!")
    end
  end

  def get_player2(filename) do
    case File.read(filename) do
      {:ok, content} ->
        content |> String.split("\n") |> Enum.at(1)
        |> String.split(":") |> Enum.at(1) |> String.trim()

      {:error, reason} ->
        IO.puts("Error reading file!")
    end
  end

  def show_data(player) do
    IO.write(Player.get_name(player))

    if Player.get_hit_pieces(player) > 0 do
      IO.write(" | " <> Integer.to_string(Player.get_hit_pieces(player)))
    end

    if Player.get_beared_pieces(player) > 0 do
      IO.write(" | " <> Integer.to_string(Player.get_beared_pieces(player)))
    end

    IO.write("\n")
  end
end
