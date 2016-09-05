require 'pry'
require_relative 'vector'
require_relative 'move'
require_relative 'piece'
require_relative 'position_reader'

class Field
  include PositionReader
  attr_accessor :position, :bmovement, :mmovement, :wmovement, :turn

  def initialize(stringified_position)
    @position = read stringified_position[0..49]
    @bmovement = read2 stringified_position[50..149]
    @mmovement = read stringified_position[150..199]
    @wmovement = read2 stringified_position[200..299]
    @turn = stringified_position[300].to_i
  end

  def to_s
    [position, bmovement, mmovement, wmovement, turn].flatten.join
  end

  def score color
    if color == :black
      by_pieces = (nb - nw) * 2
    else
      by_pieces = (nw - nb) * 2
    end
    score_by_king = by_king color

    total_score = by_pieces + score_by_king
    total_score
  end

  def by_king color
    if king_present? color
      (4 - distance_to_win(color) + 1) ** 3
    else
      -5000
    end
  end

  def king_present? color
    if color == :black
      filter = /bs/
    else
      filter = /ws/
    end

    return false if (get_pieces position, filter).empty?
    (get_pieces position, filter).first.position
  end

  def distance_to_win color
    if color == :black
      king_position = king_present? color
      win_space = [2,0]
    else
      king_position = king_present? color
      win_space = [2,4]
    end

    a = king_position[0] - win_space[0]
    b = king_position[1] - win_space[1]
    distance = Math.sqrt(a**2 + b**2)
  end

  def bpieces
    get_pieces position, /bs|bc/
  end

  def wpieces
    get_pieces position, /ws|wc/
  end

  def color
    return :black if turn == 0
    return :white if turn == 1
  end

  def moves
    case turn
    when 0
      movement = bmovement
      pieces = bpieces
    when 1
      movement = wmovement.map(&:reverse)
      pieces = wpieces
    else
      raise "don't know whose turn it is"
    end
    puts "turn: #{turn}"
    puts "pieces: #{pieces}"
    puts "movement: #{movement}"

    moveset1 = vectorify(movement.first, /kk/)
    moves = pieces.flat_map do |piece|
      moveset1.map do |move|
        Move.new(piece, move)
      end
    end
    puts "moves: #{moves.map(&:to_s)}"

    t = moves.select do |move|
      move.legal? CELLSIZE
    end
    puts "legal moves: #{t}"
    t = t.reject do |move|
      pieces.include? move.destination
    end
    puts "self-less moves: #{t}"
    t
  end

  def make move
    piece = position[move.piece.position[1]][move.piece.position[0]]
    position[move.piece.position[1]][move.piece.position[0]] = "--"
    position[move.destination.position[1]][move.destination.position[0]] = piece

    update_turn
  end

  def update_turn
    if turn == 0
      self.turn = 1
    else
      self.turn = 0
    end
  end

  def evaluate move
    future = Field.new(to_s)
    future.make move
    future.score(color)
  end

  def evaluate2 move
    future = Field.new(to_s)
    future.make move
    future.make_a_move!
    future.score(color)
  end

  def make_a_move!
    t = moves.map do |move|
      [evaluate(move), move]
    end
    #puts "t: #{t}"
    max_score = t.map{|e| e.first}.max
    #puts "max_score: #{max_score}"

    high_moves = t.select{|move| move.first == max_score}

    puts "high moves: #{high_moves}"
    picked_move = high_moves.shuffle.first[1]

    make picked_move
    picked_move
  end

  private

  def reverse movement
    movement.reverse
  end

  def nb
    position.flatten.select do |c|
      c =~ /b./
    end.map do |c|
      case c
      when /bc/; 1
      when /bs/; 500
      else; 0
      end
    end.compact.reduce(&:+)
  end

  def nw
    a = position.flatten.select do |c|
      c =~ /w./
    end
    #puts "position flatten select: #{a}"
    b = a.map do |c|
      case c
      when /wc/; 1
      when /ws/; 500
      else; 0
      end
    end.compact.reduce(&:+)
    b = -9999 if b.nil?
    #puts "b is #{b}"
    b
  end

  def vectorify movement, filter
    vectors = []
    movement.each_with_index do |r, ri|
      r.each_with_index do |c, ci|
        vectors << Vector.new([ci, ri]) if c =~ filter
      end
    end
    vectors = vectors.map{|v| v + Vector.new([-2, -2])}
  end

  def get_pieces position, filter
    pieces = []
    position.each_with_index do |r, ri|
      r.each_with_index do |c, ci|
        pieces << Piece.new([ci, ri]) if c =~ filter
      end
    end
    pieces
  end
end
