# frozen_string_literal: true

# A chess board
class Board
  SIZE = 8
  attr_reader :board

  def initialize
    @board = initial_position
  end

  def valid_move_pawn?(position, destination)
    return false unless inbound?(destination[0], destination[1])

    val = board[position[0]][position[1]]

    left = position[1] - 1
    right = position[1] + 1
    if val.negative?
      return false if board[destination[0]][destination[1]].negative?

      row = position[0] - 1
    else
      return false if board[destination[0]][destination[1]].positive?

      row = position[0] + 1
    end
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
    @board[row_pos][col_pos] = 0
    @board[row_dest][col_dest] = val
  end

  def inbound?(row, col)
    row.between(0, SIZE - 1) && col.between(0, SIZE - 1)
  end

  private

  def initial_position
    array = []
    SIZE.times { array << [0] * SIZE }
    set_first_row!(array)
    set_second_row!(array)
    array
  end

  def set_second_row!(array)
    [1, 6].each do |row|
      array[row].each_with_index do |_, index|
        array[row][index] = row == 1 ? 6 : -6
      end
    end
  end

  def set_first_row!(array)
    [0, 7].each do |row|
      curr = 5
      3.times do |ind|
        array[row][ind] = curr
        array[row][SIZE - ind - 1] = -curr
        curr -= 1
      end
      array[row][3] = row.zero? ? 2 : -2
      array[row][4] = row.zero? ? 1 : -1
    end
  end
end
