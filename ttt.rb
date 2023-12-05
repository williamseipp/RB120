# improved "join": improve prompt of available squares
# choose a position to place a piece: 1, 2, 3, 4, 5, 6, 7, 8, 9
# choose a position to place a piece: 1, 2, 3, 4, 5, 6, 7, 8 or 9

# keep score: keep score of how many times the player and computer each
#             win. Make it so that the first player to 5 wins the game.
#
# Computer AI: Defense
#
# The computer currently picks a square at random. Let the computer
#   defend immediate threats if the human player can win next turn
#   If there's no threat, computer will choose a random square as usual

# Computer AI: Offense
#
# Use the method `find_at_risk_square` from above to formulate an attack
#   strategy to place squares when it is not defending.
#
# Computer turn refinements
#
# We actually have the offense and defense steps backwards. In other
# words, if the computer has a chance to win, it should take that move
# rather than defend. As we have coded it now, it will defend first. Update
# the code so that it plays the offensive move first.
#
# b) We can make one more improvement: pick square #5 if it's available.
# The AI for the computer should go like this: first, pick the winning
# move; then, defend; then pick square #5; then pick a random square.
#
# c) Can you change the game so that the computer can move first? Ask the
# user before play begins who should go first.
#
# d) Can you add another "who goes first" option that lets the computer
# choose who goes first?
#
#
#
# Let the player pick any marker.
# Solicit a name for the player.
# Give a name to the computer, perhaps a random name from several choices you define in your code.

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = " "

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

# class Player
#   attr_reader :marker

#   def initialize(marker)
#     @marker = marker
#   end
# end

class TTTGame
  HUMAN_MARKER = "X"
  COMPUTER_MARKER = "O"
  FIRST_TO_MOVE = HUMAN_MARKER

  attr_reader :board, :human, :computer
  attr_accessor :score

  Player = Struct.new('Player', :marker)

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
    @current_marker = FIRST_TO_MOVE
    @score = { "human" => 0, "computer" => 0 }
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def main_game
    loop do
      display_board
      player_move
      update_score
      display_result
      break if grand_winner
      break unless play_again?
      reset
      display_play_again_message
    end
  end

  def update_score
    return unless board.winning_marker
    winner = board.winning_marker == HUMAN_MARKER ? "human" : "computer"
    score[winner] += 1
  end

  def play
    clear
    display_welcome_message
    main_game
    display_goodbye_message
  end

  private

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts "First to 5 wins is the grand winner!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def human_turn?
    @current_marker == HUMAN_MARKER
  end

  def display_board
    puts "You're a #{human.marker}. Computer is a #{computer.marker}."
    puts ""
    board.draw
    puts ""
  end

  def joinor(numbers, delimiter = ', ', word = 'or')
    case numbers.size
    when 0 then ''
    when 1 then numbers.first
    when 2 then "#{numbers.first} #{word} #{numbers.last}"
    else
      "#{numbers[0..-2].join(delimiter)}#{delimiter}#{word} #{numbers.last}"
    end
  end

  def human_moves
    puts "Choose a square: #{joinor(board.unmarked_keys, ', ')} "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def computer_moves
    board[board.unmarked_keys.sample] = computer.marker
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = COMPUTER_MARKER
    else
      computer_moves
      @current_marker = HUMAN_MARKER
    end
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "You won!"
    when computer.marker
      puts "Computer won!"
    else
      puts "It's a tie!"
    end
    puts "--- human: #{score['human']}   computer: #{score['computer']} ---"
    puts "#{grand_winner} is the grand winner!" if grand_winner
  end

  def grand_winner
    score.key(2)
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play another round? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n"
    end

    answer == 'y'
  end

  def clear
    system "clear"
  end

  def reset
    board.reset
    @current_marker = FIRST_TO_MOVE
    clear
  end

  def display_play_again_message
    puts "Let's play another round!"
    puts ""
  end
end

game = TTTGame.new
game.play
