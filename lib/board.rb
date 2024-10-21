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
    @piece_count = { 'wb' => 3, 'wr' => 3, 'wk' => 2, 'wq' => 2, 'wn' => 3, 'wp' => 9, 'bb' => 3, 'br' => 3, 'bk' => 2,
                     'bq' => 2, 'bn' => 3, 'bp' => 9 }
  end

  def pretty_print
    board.each_with_index do |lst, i|
      print "#{i} "
      lst.each_with_index do |curr, j|
        elm = SIGNS[curr[0]] * PIECE_NUM_MAP[curr[1]]
        print "\033#{COLORS[(i + j) % 2]};#{piece_color(elm)}m#{SHAPES[elm]}"
      end
      puts "\033[0m"
    end
    print '  '
    SIZE.times { |val| print "#{val} " }
    puts "\n\n"
  end

  def promote(position, choice) # rubocop:disable Metrics/AbcSize
    current = board[position[0]][position[1]]
    board[position[0]][position[1]] = "#{current[0]}#{choice}#{@piece_count[current[0] + choice]}"
    @piece_count[current[0] + choice] += 1
    @current_moves[board[position[0]][position[1]]] = @current_moves[current]
  end

  def promote?(position)
    row_pos, col_pos = position
    color, piece, = board[row_pos][col_pos].split('')
    return false unless [0, 7].include?(row_pos)
    return false unless piece == 'p'
    return false if color == 'w' && row_pos == 7 || color == 'b' && row_pos.zero?

    true
  end

  def find_king(color)
    board.each_with_index do |lst, i|
      lst.each_with_index do |elm, j|
        return [i, j] if elm[0] == color && elm[1] == 'k'
      end
    end
  end

  def checkmate?(color)
    board.each_with_index do |lst, i|
      lst.each_with_index do |elm, j|
        next unless elm[0] == color

        case elm[1]
        when 'k'
          board.each_with_index do |another_list, u|
            another_list.each_with_index do |_, v|
              next unless valid_move_king?([i, j], [u, v])

              return false unless another_check?([i, j], [u, v], color)
            end
          end
        when 'n'
          board.each_with_index do |another_list, u|
            another_list.each_with_index do |_, v|
              next unless valid_move_knight?([i, j], [u, v])

              return false unless another_check?([i, j], [u, v], color)
            end
          end
        when 'p'
          board.each_with_index do |another_list, u|
            another_list.each_with_index do |_, v|
              next unless valid_move_pawn?([i, j], [u, v])

              return false unless another_check?([i, j], [u, v], color)
            end
          end
        when 'q'
          board.each_with_index do |another_list, u|
            another_list.each_with_index do |_, v|
              next unless valid_move_queen?([i, j], [u, v])
              return false unless another_check?([i, j], [u, v], color)
            end
          end
        when 'b'
          board.each_with_index do |another_list, u|
            another_list.each_with_index do |_, v|
              next unless valid_move_bishop?([i, j], [u, v])
              return false unless another_check?([i, j], [u, v], color)
            end
          end
        when 'r'
          board.each_with_index do |another_list, u|
            another_list.each_with_index do |_, v|
              next unless valid_move_rook?([i, j], [u, v])

              return false unless another_check?([i, j], [u, v], color)
            end
          end
        end
      end
    end
    true
  end

  def in_check?(position)
    row_pos, col_pos = position
    color, = board[row_pos][col_pos].split('')
    board.each_with_index do |lst, i|
      lst.each_with_index do |elm, j|
        next unless elm[0] != color && elm[0] != '0'

        case elm[1]
        when 'p'
          return true if valid_move_pawn?([i, j], [row_pos, col_pos])
        when 'k'
          return true if valid_move_king?([i, j], [row_pos, col_pos])
        when 'n'
          return true if valid_move_knight?([i, j], [row_pos, col_pos])
        when 'b'
          return true if valid_move_bishop?([i, j], [row_pos, col_pos])
        when 'r'
          return true if valid_move_rook?([i, j], [row_pos, col_pos])
        when 'q'
          return true if valid_move_queen?([i, j], [row_pos, col_pos])
        end
      end
    end
    false
  end

  def castle(position, destination)
    row_pos, col_pos = position
    row_dest, col_dest = destination

    col_pos, col_dest = col_dest, col_pos if col_pos > col_dest
    if board[row_pos][col_pos][1] == 'r'
      move([row_pos, col_pos], [row_dest, col_dest - 1])
      move([row_dest, col_dest], [row_dest, col_dest - 2])
    else
      move([row_dest, col_dest], [row_dest, col_pos + 1])
      move([row_pos, col_pos], [row_dest, col_pos + 2])
    end
  end

  def castle?(position, destination)
    row_pos, col_pos = position
    row_dest, col_dest = destination
    pos_val = board[row_pos][col_pos]
    dest_val = board[row_dest][col_dest]
    return false if @current_moves[pos_val].positive? || @current_moves[dest_val].positive?

    return false if pos_val[0] != dest_val[0]

    return false unless (pos_val[1] == 'r' && dest_val[1] == 'k') || (pos_val[1] == 'k' && dest_val[1] == 'r')

    if col_pos < col_dest
      curr = col_pos + 1
      while curr < col_dest
        return false if board[row_pos][curr] != '000'

        curr += 1
      end
    else
      curr = col_pos - 1
      while curr > col_dest
        return false if board[row_pos][curr] != '000'

        curr -= 1
      end
    end
    true
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
    if curr[0] == 'w'
      row = position[0] - 1
      if board[destination[0]][destination[1]] == '000'
        if destination == [row, position[1]]
          return true
        elsif inbound?(row, position[1]) && board[row][position[1]] == '000' &&
              @current_moves[curr].zero? && destination == [row - 1, position[1]]
          return true
        end
      end

      if inbound?(row, left) && destination == [row, left]
        return true unless board[row][left] == '000'

        check = row + 1
        unless inbound?(check, left) && board[check][left][..1] == 'bp' && @current_moves[board[check][left]] == 1
          return false
        end

        board[check][left] = '000'
        true

      elsif inbound?(row, right) && destination == [row, right]
        return true unless board[row][right] == '000'

        check = row + 1
        unless inbound?(check, right) && board[check][right][..1] == 'bp' && @current_moves[board[check][right]] == 1
          return false
        end

        board[check][right] = '000'
        true
      else
        false

      end
    else
      row = position[0] + 1
      if board[destination[0]][destination[1]] == '000'
        if destination == [row, position[1]]
          return true
        elsif inbound?(row, position[1]) && board[row][position[1]] == '000' &&
              @current_moves[curr].zero? && destination == [row + 1, position[1]]
          return true
        end
      end

      if inbound?(row, left) && destination == [row, left]
        return true unless board[row][left] == '000'

        check = row - 1
        unless inbound?(check, left) && board[check][left][..1] == 'wp' && @current_moves[board[check][left]] == 1
          return false
        end

        board[check][left] = '000'
        true

      elsif inbound?(row, right) && destination == [row, right]
        return true unless board[row][right] == '000'

        check = row - 1
        unless inbound?(check, right) && board[check][right][..1] == 'wp' && @current_moves[board[check][right]] == 1
          return false
        end

        board[check][right] = '000'
        true
      else
        false

      end
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
    row.between?(0, SIZE - 1) && col.between?(0, SIZE - 1)
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

    directions.any? do |r, c|
      nr = position[0] + r
      nc = position[1] + c
      while inbound?(nr, nc) && destination != [nr, nc]
        break if board[nr][nc] != '000'

        nr += r
        nc += c
      end
      destination == [nr, nc]
    end
  end

  def valid_move_condition?(position, destination, directions)
    curr = board[position[0]][position[1]]
    val = SIGNS[curr[0]] * PIECE_NUM_MAP[curr[1]]
    return false unless reachable?(val, destination)

    directions.any? do |r, c|
      destination == [position[0] + r, position[1] + c]
    end
  end

  def another_check?(position, destination, color)
    i, j = position
    u, v = destination
    dest_val = board[u][v]
    move([i, j], [u, v])
    king_pos = find_king(color)
    ans = in_check?(king_pos)

    move([u, v], [i, j])
    board[u][v] = dest_val
    ans
  end

  def initial_position
    array = []
    array << %w[br1 bn1 bb1 bq1 bk1 bb2 bn2 br2]
    array << %w[bp1 bp2 bp3 bp4 bp5 bp6 bp7 bp8]
    4.times { array << %w[000 000 000 000 000 000 000 000] }
    array << %w[wp1 wp2 wp3 wp4 wp5 wp6 wp7 wp8]
    array << %w[wr1 wn1 wb1 wq1 wk1 wb2 wn2 wr2]
    array
  end
end
