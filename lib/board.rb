# frozen_string_literal: true

# A chess board
class Board
  SIZE = 8
  attr_reader :board

  def initialize
    @board = initial_position
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
        array[row][index] = 6
      end
    end
  end

  def set_first_row!(array)
    [0, 7].each do |row|
      curr = 5
      3.times do |ind|
        array[row][ind] = curr
        array[row][SIZE - ind - 1] = curr
        curr -= 1
      end
      array[row][3] = 2
      array[row][4] = 1
    end
  end
end
