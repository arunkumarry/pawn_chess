require_relative "board"
require_relative "player"

class Game
  attr_accessor :player1, :player2, :board, :current_turn

  def initialize
    @board = Board.new
    @player1 = Player.new(name: "ABC", indicator: 1)
    @player2 = Player.new(name: "XYZ", type: "bot", indicator: 2)
    @current_turn = @player1
    set_default_board
  end

  def set_default_board
    set_player1
    set_player2
  end

  def get_game_state
    board.board
  end

  def play(player, from_row = nil, from_col = nil, to_row = nil, to_col = nil)
    return false if game_over?
    return false if player != current_turn

    success = false
    if player.type == "bot"
      res = board.move(player)
      if res
        player.moves_history << res
        success = true
      end
    else
      if board.move(player, from_row, from_col, to_row, to_col)
        player.moves_history << [ from_row, from_col, to_row, to_col ]
        success = true
      end
    end

    if success
      @current_turn = (current_turn == player1 ? player2 : player1)
      player1.pawns = pawn_count(1)
      player2.pawns = pawn_count(2)
      true
    else
      false
    end
  end

  def pawn_count(indicator)
    board.board.flatten.count(indicator)
  end

  def winner
    # reach end
    return player1 if board.board[7].include?(1)
    return player2 if board.board[0].include?(2)

    # no pawns
    return player2 if pawn_count(1) == 0
    return player1 if pawn_count(2) == 0

    nil
  end

  def checkmate?
    board.all_legal_moves(current_turn).empty?
  end

  def game_over?
    !winner.nil? || checkmate?
  end

  private

  def set_player1
    row = 0
    while row < 2 do
      col = 0
      while col < 8 do
        board.board[row][col] = 1
        col += 1
      end
      row += 1
    end
  end

  def set_player2
    row = 7
    while row > 5 do
      col = 0
      while col < 8 do
        board.board[row][col] = 2
        col += 1
      end
      row -= 1
    end
  end
end


game = Game.new
puts game.get_game_state.inspect
