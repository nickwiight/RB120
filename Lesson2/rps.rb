class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Player.new(:human)
    @computer = Player.new(:computer)
  end

  def play
    display_welcome_message
    human.choose
    computer.choose
    display_winner
    display_goodbye_message
  end

  def display_welcome_message
    Prompt.new("Welcome to Rock, Paper, Scissors!")
  end

  def display_goodbye_message
    Prompt.new("Thanks for playing Rock, Paper, Scissors. Goodbye!")
  end

  def display_winner
    Prompt.new("You chose #{human.move.value}")
    Prompt.new("The computer chose #{computer.move.value}")
    Prompt.new(human.move.winner_message(computer.move))
  end
end

class Prompt
  def initialize(string)
    puts ">> #{string}"
  end
end

class Player
  attr_accessor :move
  
  def initialize(player_type)
    @player_type = player_type
    @move = nil
  end

  def choose
    human? ? human_choice : computer_choice
  end

  private

  def human?
    @player_type == :human
  end

  def computer_choice
    self.move = Move.new(%w(rock paper scissors).sample)
  end

  def human_choice
    choice = nil
    loop do
      Prompt.new("Choose rock, paper, or scissors:")
      choice = gets.chomp
      break if %w(rock paper scissors).include?(choice)

      Prompt.new("Invalid choice. Try again.")
    end
    self.move = Move.new(choice)
  end
end

class Move
  include Comparable
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def winner_message(other_move)
    return "You won!" if greater?(other_move)
    return "It's a tie!" if value == other_move.value
    "The computer won!"
  end

  private

  def greater?(other_move)
    return true if value == 'rock' && other_move.value == 'scissors'
    return true if value == 'paper' && other_move.value == 'rock'
    return true if value == 'scissors' && other_move.value == 'paper'
    false
  end
end

RPSGame.new.play
