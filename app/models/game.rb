class Game < ApplicationRecord
  has_many :players, dependent: :destroy
  belongs_to :current_turn_player, class_name: "Player", optional: true
  belongs_to :winner, class_name: "Player", optional: true

  before_create :initialize_game

  def self.start_game(player1_name: "ABC", player2_name: "XYZ")
    transaction do
      game = Game.create!
      p1 = game.players.create!(name: player1_name, indicator: 1, player_type: "human")
      p2 = game.players.create!(name: player2_name, indicator: 2, player_type: "bot")
      game.update!(current_turn_player: p1)
      game
    end
  end

  def player1
    players.find_by(indicator: 1)
  end

  def player2
    players.find_by(indicator: 2)
  end

  def board
    @board_wrapper ||= Board.new(board_state)
  end

  def play(player, from_row = nil, from_col = nil, to_row = nil, to_col = nil)
    return false if game_over?
    return false if player != current_turn_player

    success = false
    if player.bot?
      res = board.move(player)
      if res
        # bot, res is [from_row, from_col, to_row, to_col]
        player.moves_history << res
        player.save!
        success = true
      end
    else
      if board.move(player, from_row, from_col, to_row, to_col)
        player.moves_history << [ from_row, from_col, to_row, to_col ]
        player.save!
        success = true
      end
    end

    if success
      # update board
      self.board_state = board.board

      # turn switch
      self.current_turn_player = (current_turn_player == player1 ? player2 : player1)

      # update pawns count
      player1.update!(pawns_count: pawn_count(1))
      player2.update!(pawns_count: pawn_count(2))

      # check if won?
      if checkmate?
        self.status = "checkmate"
      elsif winning_player = determine_winner
        self.winner = winning_player
        self.status = "completed"
      end

      save!
      true
    else
      false
    end
  end

  def pawn_count(indicator)
    board_state.flatten.count(indicator)
  end

  def determine_winner
    # reach end
    return player1 if board_state[7].include?(1)
    return player2 if board_state[0].include?(2)

    # no pawns
    return player2 if pawn_count(1) == 0
    return player1 if pawn_count(2) == 0

    nil
  end

  def checkmate?
    board.all_poss_moves(current_turn_player).empty?
  end

  def game_over?
    status == "completed" || status == "checkmate"
  end

  private

  def initialize_game
    grid = Array.new(8) { Array.new(8, 0) }

    # player1 setup
    (0..1).each do |row|
      (0..7).each do |col|
        grid[row][col] = 1
      end
    end

    # player2 setup
    (6..7).each do |row|
      (0..7).each do |col|
        grid[row][col] = 2
      end
    end

    self.board_state = grid
    self.status = "active"
  end
end
