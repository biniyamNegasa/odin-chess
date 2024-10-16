# frozen_string_literal: true

# A chess board
class Board
  PIECE_NUM_MAP = { 'r' => 5, 'n' => 4, 'b' => 3, 'q' => 2, 'k' => 1, 'p' => 6, '0' => 0 }.freeze
  SIZE = 8
  SHAPES = { -6 => "\u2659 ", -5 => "\u2656 ", -4 => "\u2658 ",
             -3 => "\u2657 ", -2 => "\u2655 ", -1 => "\u2654 ",
             6 => "\u265f ", 5 => "\u265c ", 4 => "\u265e ",
             3 => "\u265d ", 2 => "\u265b ", 1 => "\u265a ", 0 => '  ' }.freeze
  COLORS = { 0 => '[47', 1 => '[100' }.freeze
  SIGNS = { 'w' => -1, 'b' => 1, '0' => 1 }.freeze
  attr_reader :board

  def initialize
    @board = initial_position
    @current_moves = Hash.new(0)
  end

  def pretty_print
    board.each_with_index do |lst, i|
      lst.each_with_index do |curr, j|
        elm = SIGNS[curr[0]] * PIECE_NUM_MAP[curr[1]]
        print "\033#{COLORS[(i + j) % 2]};#{piece_color(elm)}m#{SHAPES[elm]}"
      end
      puts "\033[0m"
    end
    puts
  end

  def reachable?(prev_val, destination)
    row, col = destination
    return false unless inbound?(row, col)

    curr = board[row][col]
    dest_val = SIGNS[curr[0]] * PIECE_NUM_MAP[curr[1]]
    return false if prev_val.negative? && dest_val.negative? || prev_val.positive? && dest_val.positive?

    true
  end

  def valid_move_knight?(position, destination)
    directions = [[1, 2], [2, 1], [2, -1], [-1, 2], [-2, 1], [1, -2], [-1, -2], [-2, -1]]
    valid_move_condition?(position, destination, directions)
  end

  def valid_move_king?(position, destination)
    directions = [[0, 1], [1, 0], [-1, 0], [0, -1], [1, 1], [1, -1], [-1, 1], [-1, -1]]
    valid_move_condition?(position, destination, directions)
  end

  def valid_move_queen?(position, destination)
    directions = [[0, 1], [1, 0], [-1, 0], [0, -1], [1, 1], [1, -1], [-1, 1], [-1, -1]]
    valid_move_loop?(position, destination, directions)
  end

  def valid_move_rook?(position, destination)
    directions = [[0, 1], [1, 0], [-1, 0], [0, -1]]
    valid_move_loop?(position, destination, directions)
  end

  def valid_move_bishop?(position, destination)
    directions = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
    valid_move_loop?(position, destination, directions)
  end

  def valid_move_pawn?(position, destination)
    curr = board[position[0]][position[1]]
    val = SIGNS[curr[0]] * PIECE_NUM_MAP[curr[1]]
    return false unless reachable?(val, destination)

    left = position[1] - 1
    right = position[1] + 1
    row = position[0] + (val.negative? ? -1 : 1)
    if (inbound?(row, left) && destination == [row, left]) ||
       (inbound?(row, right) && destination == [row, right]) ||
       (inbound?(row, left + 1) && board[row][left + 1].zero? && destination == [row, left + 1])
      true
    else
      false
    end
  end

  def move(position, destination)
    row_pos, col_pos = position
    row_dest, col_dest = destination

    val = board[row_pos][col_pos]
    @board[row_pos][col_pos] = '000'
    @board[row_dest][col_dest] = val
    @current_moves[val] += 1
  end

  def inbound?(row, col)
    row.between(0, SIZE - 1) && col.between(0, SIZE - 1)
  end

  private

  def piece_color(number)
    white = '37'
    red_on_black = '30;31'
    nothing = '1'
    if number.negative?
      white
    elsif number.positive?
      red_on_black
    else
      nothing
    end
  end

  def valid_move_loop?(position, destination, directions)
    curr = board[position[0]][position[1]]
    val = SIGNS[curr[0]] * PIECE_NUM_MAP[curr[1]]
    return false unless reachable?(val, destination)

    directions.each do |r, c|
      nr = position[0] + r
      nc = position[1] + c
      while inbound?(nr, nc) && destination != [nr, nc]
        break if board[nr][nc] != 0

        nr += r
        nc += c
      end
      return true if destination == [nr, nc]
    end
    false
  end

  def valid_move_condition?(position, destination, directions)
    curr = board[position[0]][position[1]]
    val = SIGNS[curr[0]] * PIECE_NUM_MAP[curr[1]]
    return false unless reachable?(val, destination)

    directions.each do |r, c|
      nr = position[0] + r
      nc = position[1] + c
      return true if destination == [nr, nc]
    end
    false
  end

  def initial_position
    array = []
    array << %w[br1 bn1 bb1 bq1 bk1 bb2 bn2 br2]
    array << %w[bp1 bp2 bp3 bp4 bp5 bp6 bp7 bp8]
    4.times { array << %w[000 000 000 000 000 000 000 000] }
    array << %w[wr1 wn1 wb1 wq1 wk1 wb2 wn2 wr2]
    array << %w[wp1 wp2 wp3 wp4 wp5 wp6 wp7 wp8]
    array
  end
end
