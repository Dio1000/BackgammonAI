Code.require_file("backgammon/game/game_headers.exs")
Code.require_file("backgammon/game/game_round.exs")
Code.require_file("backgammon/player/player_builder.exs")

defmodule GameController do
  def start_game() do
    GameHeaders.start_header()
    get_choice()
    GameHeaders.end_header()
  end

  defp play_against_human() do
    IO.write("\n")

    player = PlayerBuilder.default_build()
    opponent = PlayerBuilder.default_build()
    GameRound.start_round(player, opponent)

    get_choice()
  end

  defp play_against_AI() do
    IO.write("\n")

    player = PlayerBuilder.default_build()
    opponent = PlayerBuilder.default_build()
    GameRound.start_round(player, opponent)

    get_choice()
  end

  defp player_settings() do
    IO.write("\n")

    filename = "backgammon/files/player_data.txt"
    if !File.exists?(filename) do
      text = "Player1:\nPlayer2:"
      File.write!(filename, text)
    end

    case File.read(filename) do
      {:ok, content} ->
        player_settings_change(filename, content)
        IO.puts("Settings were saved!\n")
      {:error, reason} ->
        IO.puts("Error reading file: #{reason}")
    end

    get_choice()
  end

  defp player_settings_change(filename, content) do
    IO.puts("Your current settings are:")
    content
    |> String.split("\n", trim: true)
    |> Enum.each(&IO.puts/1)

    new_content1 = "Player1: " <> IO.gets("New Player1: ") |> to_string |> String.trim()
    new_content2 = "Player2: " <> IO.gets("New Player2: ") |> to_string |> String.trim()

    File.write!(filename, new_content1 <> "\n" <> new_content2)
  end

  defp player_exit() do
    GameHeaders.exit_header()
    System.stop(0)
  end

  defp get_choice() do
    choice = IO.gets("Choice: ")
    |> String.trim()

    case Integer.parse(choice) do
      {num, _} when num in 1..4 -> handle_choice(num)
      _ -> get_choice_fail()
    end
  end

  defp handle_choice(1), do: play_against_human()

  defp handle_choice(2), do: play_against_AI()

  defp handle_choice(3), do: player_settings()

  defp handle_choice(4), do: player_exit()

  defp handle_choice(_), do: get_choice_fail()

  defp get_choice_fail() do
    IO.puts("Sorry for this primitive UI! Please choose a valid option (1 - 4)!")
    get_choice()
  end
end
