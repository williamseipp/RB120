# I don't think creating separate classes of Move
# is a good design decision for several reasons
#
# first, the type of move doesnt have any intrinsic value
# on its own; its value is compared against another and that's it
# if we were talk about say... a wizard duel and have two wizards
# throw different classes of magic at each other then there might
# be different attributes of a magic spell, such as cast time, or
# lingering effects, or range, etc
# these subclasses of Moves written as-is don't have a distinguishing
# feature other than their type and the list of other moves they
# beat.

# second, its difficult to see what the win/lose conditions are for
#   the entire set of moves. If we wanted to change them, or even
#   describe them we'd have to look at multiple classes.
#
#   I could have kept the hashes for winning and losing combinations
#   as part of the Move class but this would be redundant.
#
# third, I have to create another set of logic to create the particular
#   "type" of Move for both the player and the computer. Ten lines of
#   code for what? To substitute a custom class for a String?
#   "Much ado about Nothing"
#
# the benefit is that the winning / losing combinations are gone
# and the comparing methods #< and #> have shrunk by a little

class Move
  attr_reader :value

  VALUES = ['rock', 'paper', 'scissors', 'lizard', 'spock']

  def initialize(value)
    @value = value
  end

  def >(other_move)
    wins_against.include?(other_move.value)
  end

  def <(other_move)
    loses_against.include?(other_move.value)
  end

  def to_s
    @value
  end
end

class Rock < Move
  def wins_against
    ['scissors', 'lizard']
  end

  def loses_against
    ['paper', 'spock']
  end
end

class Paper < Move
  def wins_against
    ['rock', 'spock']
  end

  def loses_against
    ['scissors', 'lizard']
  end
end

class Scissors < Move
  def wins_against
    ['paper', 'lizard']
  end

  def loses_against
    ['lizard', 'spock']
  end
end

class Lizard < Move
  def wins_against
    ['paper', 'spock']
  end

  def loses_against
    ['rock', 'scissors']
  end
end

class Spock < Move
  def wins_against
    ['rock', 'scissors']
  end

  def loses_against
    ['paper', 'lizard']
  end
end

class Player
  attr_accessor :move, :name, :wins

  def initialize
    set_name
    self.wins = 0
  end
end

class Human < Player
  def set_name
    n = ''
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?

      puts 'Sorry, must enter a value.'
    end
    self.name = n
  end

  def prompt_choice
    loop do
      puts 'Please choose rock, paper, scissors, lizard, or spock:'
      choice = gets.chomp
      return choice if Move::VALUES.include? choice
      puts 'Sorry, invalid choice.'
    end
  end

  def choose
    choice = prompt_choice
    self.move = Rock.new(choice) if choice == 'rock'
    self.move = Paper.new(choice) if choice == 'paper'
    self.move = Scissors.new(choice) if choice == 'scissors'
    self.move = Lizard.new(choice) if choice == 'lizard'
    self.move = Spock.new(choice) if choice == 'spock'
  end
end

class Computer < Player
  def set_name
    self.name = %w(R2D2 Hal GlaDOS).sample
  end

  def choose
    choice = (Move::VALUES.sample)
    self.move = Rock.new(choice) if choice == 'rock'
    self.move = Paper.new(choice) if choice == 'paper'
    self.move = Scissors.new(choice) if choice == 'scissors'
    self.move = Lizard.new(choice) if choice == 'lizard'
    self.move = Spock.new(choice) if choice == 'spock'
  end
end

class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts 'Welcome to Rock, Paper, Scissors, Lizard, Spock!'
    puts 'First one to ten wins is the grand winner!'
  end

  def display_goodbye_message
    puts 'Thanks for playing Rock, Paper, Scissors, Lizard, Spock. Good bye!'
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def winner
    if human.move > computer.move
      human
    elsif human.move < computer.move
      computer
    end
  end

  def display_winner
    puts winner.nil? ? "It's a tie!" : "#{winner.name} won!"
  end

  def display_grand_winner
    the_winner = [human, computer].find { |player| player.wins == 10 }
    return unless the_winner
    puts "#{the_winner.name} is the first one to 10 wins! Congragulations!"
  end

  def update_score
    return unless winner
    winner.wins += 1
  end

  def play_again?
    answer = nil
    loop do
      puts 'Would you like to play again? (y/n)'
      answer = gets.chomp
      break if %w(y n).include? answer.downcase
    end
    answer == 'y'
  end

  def grand_winner
    [human, computer].any? { |player| player.wins == 10 }
  end

  def play
    display_welcome_message
    loop do
      human.choose
      computer.choose
      display_moves
      display_winner
      update_score
      break unless play_again? && grand_winner == false
    end
    display_grand_winner
    display_goodbye_message
  end
end

RPSGame.new.play
