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
end

class RPSGame
  include Promptable
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
    @score = ScoreManager.new
  end

  def play
    system 'clear'
    display_welcome_message
    extended_rules
    set_score_goal
    ready
    game_loop
    game_over
  end

  private

  attr_accessor :extended
  attr_reader :score

  def game_loop
    loop do
      system 'clear'
      score.display_score
      human.choose(extended)
      computer.choose(extended)
      display_winner

      break if end?
    end
  end

  def display_welcome_message
    prompt_and_wait("Welcome to Rock, Paper, Scissors!")
  end

  def extended_rules
    prompt("Do you want to play with extended rules?")
    prompt("This adds 'Lizard' and 'Spock' to the available moves.")
    prompt("Please enter 'y' or 'n'.")
    self.extended = y_n?
    string = extended ? "Playing with extended rules" : "Extended rules disabled"
    prompt_and_wait(string)
  end

  def set_score_goal
    prompt("How many points to win?")
    goal = nil
    loop do
      goal = gets.chomp

      break if valid_score_goal?(goal)
      prompt("Invalid imput. Please enter an integer greater than 0")
    end
    score.goal = goal.to_i
  end

  def valid_score_goal?(string)
    return false if string.to_i.to_s != string
    return false if string.to_i < 1
    true
  end

  def ready
    prompt("First to #{score.goal} points wins!")
    prompt("Press enter to begin.")
    gets.chomp
  end

  def game_over
    display_break
    prompt_and_wait("Game over!")
    prompt_and_wait(winner_message)
    score.display_score
    sleep(0.5)
    display_break
    prompt("See history?")
    score.display_history if y_n?
    display_goodbye_message
  end

  def winner_message
    h_score = score.score[:human]
    c_score = score.score[:computer]
    h_score > c_score ? "You won!" : "The computer won!"
  end

  def display_goodbye_message
    display_break
    prompt_and_wait("Thanks for playing Rock, Paper, Scissors.")
    prompt("Goodbye!")
  end

  def display_winner
    display_break
    prompt("You chose %s", human.move.value)
    prompt("The computer chose %s", computer.move.value)
    prompt_and_wait(determine_winner)
  end

  def determine_winner
    winner = human.move <=> computer.move
    case winner
    in 1 then human_win
    in 0 then tie
    in -1 then computer_win
    end
  end

  def human_win
    score.update_score(:human)
    score.update_history(human.move, computer.move, "You won!")
    "You won!"
  end

  def tie
    score.update_score(:tie)
    score.update_history(human.move, computer.move, "Tie!")
    "It's a tie!"
  end

  def computer_win
    score.update_score(:computer)
    score.update_history(human.move, computer.move, "Computer won!")
    "The computer won!"
  end

  def end?
    return true if score.score_met_goal?
    display_break
    prompt("Press enter to continue.")
    gets.chomp
    false
  end
end

class ScoreManager
  include Promptable
  attr_accessor :goal
  attr_reader :score

  def initialize
    @score = {
      human: 0,
      computer: 0,
      tie: 0
    }
    @history = []
  end

  def update_score(key)
    score[key] += 1
  end

  def update_history(human_move, computer_move, message)
    history << [human_move, computer_move, message]
  end

  def display_score
    human = "You: #{score[:human]}"
    ties = "Ties: #{score[:tie]}"
    computer = "Computer: #{score[:computer]}"
    puts "#{human} <-- #{ties} --> #{computer}"
  end

  def display_history
    history.each_with_index do |round, index|
      round_message = "Round #{index + 1}:"
      human_move = "You played #{round[0].value};"
      computer_move = "Computer played #{round[1].value};"
      message = round[2]
      prompt "#{round_message} #{human_move} #{computer_move} #{message}"
    end
  end

  def score_met_goal?
    [score[:human], score[:computer]].any? { |n| n >= goal }
  end

  private

  attr_accessor :history
end

class Player
  attr_accessor :move

  def choose
    puts "#{self} not implemented #choose"
  end
end

class Human < Player
  include Promptable

  def choose(extended)
    choice = nil
    loop do
      prompt(choose_message(extended))
      choice = gets.chomp
      break if Move.valid_move?(choice, extended)

      prompt("Invalid choice. Try again.")
    end
    self.move = Move.new(Move.convert_string_to_move(choice, extended),
                         extended)
  end

  private

  def choose_message(extended)
    moves = Move.all_valid_moves(extended).clone
    moves.map!(&:to_s)
    moves[-1] = "or #{moves[-1]}"
    "Choose #{moves.join(', ')}"
  end
end

class Computer < Player
  def choose(extended)
    self.move = Move.new(Move.all_valid_moves(extended).sample, extended)
  end
end

class Move
  MOVES = {
    rock: {
      strings: %w(rock r),
      beats: [:scissors, :lizard]
    },
    paper: {
      strings: %w(paper p),
      beats: [:rock, :spock]
    },
    scissors: {
      strings: %w(scissors s),
      beats: [:paper, :lizard]
    }
  }
  EXTENDED_MOVES = {
    lizard: {
      strings: %w(lizard l),
      beats: [:spock, :paper]
    },
    spock: {
      strings: %w(spock sp),
      beats: [:rock, :scissors]
    }
  }
  include Comparable
  attr_reader :value

  def initialize(value, extended)
    @value = value
    @extended = extended
  end

  def <=>(other_move)
    if greater?(other_move)
      1
    elsif value == other_move.value
      0
    else
      -1
    end
  end

  def self.valid_move?(string, extended)
    hash = extended ? MOVES.merge(EXTENDED_MOVES) : MOVES
    hash.any? { |_, value| value[:strings].any?(string) }
  end

  def self.convert_string_to_move(string, extended)
    hash = extended ? MOVES.merge(EXTENDED_MOVES) : MOVES
    hash.each do |key, value|
      return key if value[:strings].any?(string)
    end
  end

  def self.all_valid_moves(extended)
    hash = extended ? MOVES.merge(EXTENDED_MOVES) : MOVES
    hash.keys
  end

  private

  attr_reader :extended

  def greater?(other_move)
    hash = extended ? MOVES.merge(EXTENDED_MOVES) : MOVES
    hash[value][:beats].include?(other_move.value)
  end
end

RPSGame.new.play
