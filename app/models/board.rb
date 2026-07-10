class Board
  attr_accessor :board

  def initialize
    @board = Array.new(8) { Array.new(8, 0) }
  end

  def move(player, from_row = nil, from_col = nil, to_row = nil, to_col = nil)
    if player.type == "bot"
      bot_move(player)
    else
      if legal_move?(player, from_row, from_col, to_row, to_col)
        board[from_row][from_col] = 0
        board[to_row][to_col] = player.indicator
        true
      else
        false
      end
    end
  end

  def legal_move?(player, from_row, from_col, to_row, to_col)
    return false if from_row.nil? || from_col.nil? || to_row.nil? || to_col.nil?
    return false if out_of_bounds?(from_row, from_col) || out_of_bounds?(to_row, to_col)
    return false if board[from_row][from_col] != player.indicator

    dir = player.indicator == 1 ? 1 : -1
    row_diff = to_row - from_row
    col_diff = (to_col - from_col).abs

    if col_diff == 0
      # move forward
      return false if board[to_row][to_col] != 0

      row_diff == dir
    elsif col_diff == 1 && row_diff == dir
      # capture diagonally
      opponent_indicator = player.indicator == 1 ? 2 : 1
      board[to_row][to_col] == opponent_indicator
    else
      false
    end
  end

  def out_of_bounds?(row, col)
    row < 0 || row >= board.length || col < 0 || col >= board[0].length
  end

  def all_poss_moves(player)
    moves = []
    board.each_with_index do |row, r|
      row.each_with_index do |cell, c|
        if cell == player.indicator
          dir = player.indicator == 1 ? 1 : -1

          # forward
          moves << { from: [ r, c ], to: [ r + dir, c ] } if legal_move?(player, r, c, r + dir, c)
          # left
          moves << { from: [ r, c ], to: [ r + dir, c - 1 ] } if legal_move?(player, r, c, r + dir, c - 1)
          # right
          moves << { from: [ r, c ], to: [ r + dir, c + 1 ] } if legal_move?(player, r, c, r + dir, c + 1)
        end
      end
    end
    moves
  end

  private

  def bot_move(player)
    moves = all_poss_moves(player)
    return false if moves.empty?

    # forst try capturing
    captures = moves.select { |m| board[m[:to][0]][m[:to][1]] != 0 }
    selected_move = captures.any? ? captures.sample : moves.sample

    from_r, from_c = selected_move[:from]
    to_r, to_c = selected_move[:to]

    board[from_r][from_c] = 0
    board[to_r][to_c] = player.indicator

    [ from_r, from_c, to_r, to_c ]
  end
end
