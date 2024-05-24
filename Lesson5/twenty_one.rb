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

  def await_enter
    prompt "Press enter to continue"
    gets
  end
end

module Hand
  attr_reader :cards

  def clear_hand
    cards.clear
  end

  def hit(card)
    cards << card
  end

  def bust?
    score > 21
  end

  def score
    points = cards.map(&:score).inject(&:+)
    ace_adjustment(points)
  end

  def display_hand
    cards.map(&:to_s).join(', ')
  end

  private

  def ace_count
    cards.count(&:ace?)
  end

  def ace_adjustment(value)
    return value if value <= 21

    ace_count.times do |_|
      value -= 10
      return value if value <= 21
    end

    value
  end
end

class Participant
  include Hand, Promptable

  def initialize
    @cards = []
  end
end

class Player < Participant
  def play
    loop do
      prompt_and_wait "Your hand is worth #{score}."
      prompt "Hit? (y/n)"
      break unless y_n?

      card = Deck.deal
      hit(card)
      prompt "You drew #{card}"
      display_break
      break if bust?
    end
  end
end

class Dealer < Participant
  MIN_SCORE = 17

  def display_initial_hand
    pretty_hand = cards.map(&:to_s)
    pretty_hand[-1] = 'Facedown card'
    pretty_hand.join(', ')
  end

  def play(score_to_beat)
    turn_start_display
    while score < MIN_SCORE || score < score_to_beat
      card = Deck.deal
      hit(card)
      prompt_and_wait("Dealer drew #{card}")
      prompt_and_wait("Dealer's score is #{score}")
      display_break
    end
  end

  def turn_start_display
    prompt "Dealer's full hand is: "
    prompt display_hand
    prompt_and_wait("Dealer's score is #{score}")
    display_break
  end
end

class Card
  SUITS = %w(Clubs Diamonds Hearts Spades)
  VALUES = [:Ace, 2, 3, 4, 5, 6, 7, 8, 9, :Jack, :Queen, :King]

  def initialize(suit, face)
    @suit = suit
    @face = face
  end

  def score
    case @face
    when :Ace
      11
    when :Jack, :Queen, :King
      10
    else
      @face
    end
  end

  def ace?
    @face == :Ace
  end

  def to_s
    "#{@face} of #{@suit}"
  end
end

class Deck
  @@cards = []

  def self.deal
    @@cards.pop
  end

  def self.reset
    @@cards.clear

    Card::SUITS.each do |suit|
      Card::VALUES.each do |value|
        @@cards << Card.new(suit, value)
      end
    end

    @@cards.shuffle!
  end
end

class Game
  include Promptable

  attr_reader :player, :dealer

  def initialize
    @player = Player.new
    @dealer = Dealer.new
    Deck.reset
  end

  def play
    display_welcome_message
    game_loop
  end

  def game_loop
    deal_cards
    show_initial_cards
    player.play
    dealer.play(player.score) unless player.bust?
    show_result
    play_again
  end

  def display_welcome_message
    clear
    prompt "Welcome to Twenty One!"
    display_break
  end

  def deal_cards
    2.times do |_|
      player.hit(Deck.deal)
      dealer.hit(Deck.deal)
    end
  end

  def show_initial_cards
    prompt "Dealer's hand is:"
    prompt_and_wait dealer.display_initial_hand
    display_break
    prompt "Your hand is:"
    prompt_and_wait player.display_hand
    display_break
  end

  def show_result
    if player.bust?
      prompt "You busted!"
    elsif dealer.bust?
      prompt "Dealer busted!"
    end
    prompt "It's a tie!" if player.score == dealer.score
    display_fancy(determine_winner == player ? "You won!" : "Dealer won!")
    sleep(0.5)
  end

  def determine_winner
    winner = nil
    winner = dealer if player.bust?
    winner = player if dealer.bust?
    winner ||= player if player.score > dealer.score
    winner ||= dealer
    winner
  end

  def play_again
    prompt "Play again?"
    if y_n?
      reset
      game_loop
    else
      display_end_message
    end
  end

  def reset
    Deck.reset
    player.clear_hand
    dealer.clear_hand
    clear
  end

  def display_end_message
    prompt_and_wait("Thanks for playing Twenty One.")
    prompt("Goodbye!")
  end

  def display_fancy(message)
    width = 36
    fancy_message = "~#{message}~"
    puts "+-#{'-' * width}-+"
    puts "| #{' ' * width} |"
    puts "| #{fancy_message.center(width)} |"
    puts "| #{' ' * width} |"
    puts "+-#{'-' * width}-+"
  end
end

Game.new.play
