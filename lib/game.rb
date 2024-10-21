# frozen_string_literal: true

require_relative 'board'

# Logic of the chess game
class Game
  attr_reader :player_turn, :kings_color, :board

  def initialize
    @board = Board.new
    @kings_color = { 0 => 'white', 1 => 'black' }
    @player_turn = 0
  end

  def won?(player)
    enemy = (player + 1) % 2
    color = kings_color[enemy]
    board.in_check?(board.find_king(color[0])) && board.checkmate?(color[0])
  end

  def play
    welcome_message
    board.pretty_print
    loop do
      puts "It's your turn player #{player_turn + 1}, who is playing as a #{kings_color[player_turn]}"
      src, dest = user_input
      single_move(src, dest)
      clear_terminal
      board.pretty_print
      break if won?(player_turn)

      @player_turn = (@player_turn + 1) % 2
    end
    congratulations_message
  end

  def single_move(source, destination)
    shape = board.board[source[0]][source[1]][1]

    case shape
    when 'r'
      if board.valid_move_rook?(source, destination)
        board.move(source, destination)
      elsif board.castle?(source, destination)
        board.castle(source, destination)
      else
        error_message
        a, b = user_input
        single_move(a, b)
      end
    when 'b'
      if board.valid_move_bishop?(source, destination)
        board.move(source, destination)
      else
        error_message
        a, b = user_input
        single_move(a, b)
      end
    when 'k'
      if board.valid_move_king?(source, destination)
        board.move(source, destination)
      elsif board.castle?(source, destination)
        board.castle(source, destination)
      else
        error_message
        a, b = user_input
        single_move(a, b)
      end
    when 'p'
      if board.valid_move_pawn?(source, destination)
        board.move(source, destination)
        board.promote(destination, promotion_input) if board.promote?(destination)
      else
        error_message
        a, b = user_input
        single_move(a, b)
      end
    when 'q'
      if board.valid_move_queen?(source, destination)
        board.move(source, destination)
      else
        error_message
        a, b = user_input
        single_move(a, b)
      end
    when 'n'
      if board.valid_move_knight?(source, destination)
        board.move(source, destination)
      else
        error_message
        a, b = user_input
        single_move(a, b)
      end
    else
      error_message
      a, b = user_input
      single_move(a, b)
    end
  end

  def promotion_input
    puts "Enter value to promote your pawn: q - queen
                                            n - knight
                                            b - bishop
                                            r - rook"
    data = gets.chomp.downcase
    return data if %w[q n b r].include?(data)

    puts 'You have to enter one of the specified characters'
    promotion_input
  end

  def clear_terminal
    puts "\e[H\e[2J"
  end

  def user_input
    data = gets.chomp
    if data.length == 7 && data =~ /^((?:\d?)(?:[ \t]|$))*$/
      a, b, c, d = data.split.map(&:to_i)
      if board.inbound?(a, b) && board.inbound?(c, d) && kings_color[player_turn][0] == board.board[a][b][0]
        return [[a, b], [c, d]]
      end
    end
    error_message
    user_input
  end

  def congratulations_message
    puts "The winner is player #{player_turn + 1}, who was playing as a #{kings_color[player_turn]}"
  end

  def error_message
    puts "That's an invalid move! Please put a valid move. :)"
  end

  def welcome_message
    puts "Welcome! This a terminal based chess game.
    You move pieces by using the rows and columns index like this: 6 4 5 4
    Where the first two digits imply the source and the last two digits imply the destination
    The first player, who is player 1, is white always!
    "
  end
end