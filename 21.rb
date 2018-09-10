require 'pry'

class Participant
  attr_reader :name
  attr_accessor :cards

  def initialize
    @cards = []
  end

  def hit(deck)
    puts "#{name} chose to hit!"
    card = deck.pop
    @cards << card
    puts "#{name} drew #{card}!"
  end

  def stay
    puts "#{name} chose to stay!"
  end

  def busted?
    total > 21
  end

  def total
    total = 0
    @cards.each do |card|
      total += (card.ace? ? 11 : card.value)
    end

    cards.select(&:ace?).count.times do
      break if total <= 21
      total -= 10
    end

    total
  end

  def show_total
    puts "#{name} has a total of #{total}"
  end

  def draw(deck)
    @cards << deck.pop
  end
end

class Player < Participant
  def initialize
    super
    @name = 'Player'
  end

  def show_cards
    hand = []
    cards.each { |card| hand << card.to_s }
    puts "You have #{hand.join(', ')} with a total of #{total}"
  end

  def turn(deck)
    loop do
      if hit_or_stay == 'h'
        hit(deck)
        show_total
        break if busted?
      else
        stay
        break
      end
    end
  end

  def hit_or_stay
    answer = ''
    show_cards
    loop do
      puts '(h)it or (s)tay?'
      answer = gets.chomp
      break if %w(h s).include? answer
      puts "Invalid, please enter h or s."
    end
    system 'clear'
    answer
  end
end

class Dealer < Participant
  def initialize
    super
    @name = 'Dealer'
  end

  def show_cards
    hand = []
    cards.each { |card| hand << card.to_s }
    puts "Dealer has #{hand[0]} face up"
  end

  def turn(deck)
    loop do
      if total < 17
        hit(deck)
      else
        stay
        break
      end
    end
  end
end

class Deck
  attr_reader :deck
  RANKS = (2..10).to_a + %w(Jack Queen King Ace).freeze
  SUITS = %w(Hearts Clubs Diamonds Spades).freeze

  def initialize
    reset
  end

  def reset
    @deck = RANKS.product(SUITS).map do |rank, suit|
      Card.new(rank, suit)
    end

    @deck.shuffle!
  end

  def pop
    @deck.pop
  end
end

class Card
  attr_accessor :rank, :suit
  VALUES = { 'Jack' => 10, 'Queen' => 10, 'King' => 10, 'Ace' => 10 }.freeze

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def value
    VALUES.fetch(@rank, @rank)
  end

  def to_s
    "#{@rank} of #{@suit}"
  end

  def ace?
    rank == 'Ace'
  end
end

class Game
  attr_reader :player, :dealer, :deck

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def reset
    deck.reset
    player.cards = []
    dealer.cards = []
  end

  def start
    loop do
      reset
      display_welcome_message
      deal_cards
      show_initial_cards
      player_turn
      dealer_turn if !player.busted?
      show_result
      break unless play_again?
    end
    display_goodbye_message
  end

  def play_again?
    answer = ''
    loop do
      puts "Would you like to go again? (y) (n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
    end
    return true if answer == 'y'
  end

  def display_welcome_message
    system 'clear'
    puts "Welcome to 21!"
  end

  def display_goodbye_message
    puts "Goodbye!"
  end

  def deal_cards
    puts "Dealing cards..."
    2.times { player.draw(@deck) }
    2.times { dealer.draw(@deck) }
  end

  def show_initial_cards
    dealer.show_cards
  end

  def player_turn
    player.turn(@deck)
  end

  def dealer_turn
    dealer.turn(@deck)
  end

  def show_totals
  end

  def show_totals_and_winner
    player.show_totals
    dealer.show_totals
    if player.total > dealer.total
      puts "Player wins!"
    elsif dealer.total > player.total
      puts "Dealer wins!"
    else
      puts "Push!"
    end
  end

  def show_result
    if player.busted?
      puts "Player busted, dealer wins!"
    elsif dealer.busted?
      puts "Dealer busted, player wins!"
    else
      show_totals_and_winner
    end
  end
end

Game.new.start
