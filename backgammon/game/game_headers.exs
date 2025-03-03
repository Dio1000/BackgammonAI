defmodule GameHeaders do
  def start_header() do
    IO.puts("                  Welcome to Backgammon!                   ")
    IO.puts("1. Play a game against another person from the same machine")
    IO.puts("2. Play a game against an AI that plays the best moves")
    IO.puts("3. Settings")
    IO.puts("4. Exit")
  end

  def end_header() do
    IO.puts("Thank you for playing!")
  end

  def exit_header() do
    IO.puts("See you next time!")
  end
end
