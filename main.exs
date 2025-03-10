Code.require_file("backgammon/game/game_controller.exs")
Code.require_file("backgammon/game/game_validator.exs")
Code.require_file("backgammon/domain/board.exs")
Code.require_file("backgammon/domain/board_utils.exs")
Code.require_file("backgammon/engine/move_generator.exs")
Code.require_file("backgammon/engine/engine.exs")
Code.require_file("backgammon/player/player_builder.exs")

# GameController.start_game()
board = Board.create()
player = PlayerBuilder.default_build_white("player")
opponent = PlayerBuilder.default_build_black("AI")
dice_roll = [5, 3]

game_state = MoveGenerator.new(board, player, opponent, dice_roll)

Board.show(board)
IO.inspect(GameEngine.choose_best_move(game_state))
