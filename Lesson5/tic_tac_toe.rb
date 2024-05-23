module Promptable
  def prompt(string, *args)
    puts(args.empty? ? ">> #{string}" : ">> #{string % args}")
  end

  def prompt_and_wait(string, *args, time: 0.5)
    prompt(string, *args)
    sleep(time)
  end

  def y_n?
    choice = nil
    loop do
      choice = gets.chomp
      break if %w(y n).include? choice.downcase
      prompt("Invalid choice. Please enter 'y' or 'n'")
    end
    choice == 'y'
  end

  def display_break
    puts ""
  end

  def clear
    system 'clear'
  end
end

class Board
  include Promptable
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9], # rows
                   [1, 4, 7], [2, 5, 8], [3, 6, 9], # columns
                   [1, 5, 9], [3, 5, 7]]            # diagonals

  attr_accessor :squares

  def initialize
    @squares = {}
    reset
  end

  def display
    prompt "You are #{TTTGame::HUMAN_MARKER}. " \
           "Computer is #{TTTGame::COMPUTER_MARKER}"
    puts ''
    puts board_row(row(0))
    puts "---+---+---"
    puts board_row(row(1))
    puts "---+---+---"
    puts board_row(row(2))
    puts ''
  end

  def available_squares
    @squares.keys.select do |key|
      get_square_at(key).unmarked?
    end
  end

  def full?
    available_squares.empty?
  end

  def winner?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      return squares.first.marker if identical_line?(squares)
    end
    nil
  end

  def identical_line?(squares)
    markers = squares.select(&:marked?).map(&:marker)
    return false if markers.size != 3
    markers.uniq.length == 1
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def board_row(row)
    first = get_square_at(row[0])
    second = get_square_at(row[1])
    third = get_square_at(row[2])
    " #{first} | #{second} | #{third} "
    # " #{row[0]} | #{row[1]} | #{row[2]} "
  end

  def index_or_marker(index)
    get_square_at(index).unmarked? ? index : get_square_at(index)
  end

  def row(row_number)
    offset = row_number * 3
    [(1 + offset), (2 + offset), (3 + offset)]
  end

  def get_square_at(key)
    @squares[key]
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end
end

class Square
  INITIAL_MARKER = " "
  attr_accessor :marker

  def initialize
    @marker = INITIAL_MARKER
  end

  def marked?
    @marker != INITIAL_MARKER
  end

  def unmarked?
    @marker == INITIAL_MARKER
  end

  def to_s
    @marker
  end
end

class Player
  attr_reader :marker

  def initialize(marker)
    @marker = marker
    # marker symbol?
  end
end

class TTTGame
  include Promptable

  HUMAN_MARKER = 'X'
  COMPUTER_MARKER = 'O'

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
  end

  def play
    display_welcome_message
    loop do
      game_loop
      display_results

      break unless play_again?
      reset
    end
    display_goodbye_message
  end

  def game_loop
    loop do
      clear
      board.display
      human_move
      break if game_end?

      computer_move
      break if game_end?
    end
  end

  def reset
    board.reset
    clear
    prompt "Let's play again!"
    display_break
    prompt "Press enter to continue"
    gets
  end

  def display_welcome_message
    prompt "Welcome to Tic Tac Toe!"
    display_break
    prompt "Press enter to continue"
    gets
  end

  def display_results
    clear
    board.display

    case board.winning_marker
    when human.marker
      prompt "You won!"
    when computer.marker
      prompt "Computer won!"
    else
      prompt "It's a tie!"
    end
  end

  def play_again?
    prompt "Would you like to play again? (y/n)"
    y_n?
  end

  def display_goodbye_message
    prompt_and_wait "Thanks for playing Tic Tac Toe."
    prompt "Goodbye"
  end

  def human_move
    moves = board.available_squares.map(&:to_s)
    moves[-1] = "or #{moves[-1]}"
    square = nil
    loop do
      prompt "Choose #{moves.join(', ')}:"
      square = gets.chomp.to_i
      break if board.available_squares.include?(square)
      prompt "Invalid input. Enter an available move."
    end
    board[square] = human.marker
  end

  def computer_move
    move = board.available_squares.sample
    board[move] = computer.marker
  end

  def game_end?
    board.full? || board.winner?
  end
end

TTTGame.new.play
