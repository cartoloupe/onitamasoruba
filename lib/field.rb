require 'pry'
require_relative 'vector'
require_relative 'move'
require_relative 'piece'
require_relative 'position_reader'
require_relative 'movement'

class Field
  include PositionReader
  attr_accessor :position, :bmovement, :mmovement, :wmovement, :turn

  def initialize(stringified_position)
    @position = read stringified_position[0..49]
    @bmovement = [
      Movement.new(stringified_position[50..99]),
      Movement.new(stringified_position[100..149]),
    ]
    @mmovement = Movement.new(stringified_position[150..199])
    @wmovement = [
      Movement.new(stringified_position[200..249]),
      Movement.new(stringified_position[250..299]),
    ]
    @turn = stringified_position[300].to_i
  end

  def movements
    [bmovement, mmovement, wmovement].flatten.join

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

  def valid_moves
    Rails.logger.info "moves.to_s:"
    Rails.logger.info moves.map(&:to_s)
    grouped =
      moves
      .map{|move|
        [move.piece.coordinates, move.destination.coordinates]
      }
      .group_by{|coordinates, _| coordinates}

    grouped.keys.each{|k|
      grouped[k] = grouped[k].map{|src,dst| dst}
    }

    Rails.logger.info "valid_moves:"
    Rails.logger.info grouped
    grouped
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

    moveset1 = vectorify(movement.first, /kk/)
    moves = pieces.flat_map do |piece|
      moveset1.map do |move|
        Move.new(piece, move, movement.first)
      end
    end

    Rails.logger.info "all moves:"
    Rails.logger.info moves.map(&:to_s)
    t = moves.select do |move|
      move.legal? CELLSIZE
    end
    t = t.reject do |move|
      pieces.include? move.destination
    end
    t
  end

  def make move
    piece_x       = move.piece.position[1]
    piece_y       = move.piece.position[0]
    destination_x = move.destination.position[1]
    destination_y = move.destination.position[0]

    piece = position[piece_x][piece_y]
            position[piece_x][piece_y] = "--"
            position[destination_x][destination_y] = piece

    update_movements move.movement
    update_turn
  end

  def update_movements movement
    if turn == 0
      self.bmovement = self.bmovement.reject{|m| m == movement} << mmovement
    else
      self.wmovement = self.wmovement.reject{|m| m == movement} << mmovement
    end
    self.mmovement = movement
  end

  def update_turn
    if turn == 0
      self.turn = 1
    else
      self.turn = 0
    end
  end

  def evaluate1 move
    future = Field.new(to_s)
    future.make move
    future.score(color)
  end

  def evaluate2 move
    future = Field.new(to_s)
    future.make move
    future.make_a_move! :evaluate1
    future.score(color)
  end

  def evaluate3 move
    future = Field.new(to_s)
    future.make move
    future.make_a_move! :evaluate2
    #puts "\tevaluate3:: best black score: #{future.score(:black)}"
    #puts "\tevaluate3:: best white score: #{future.score(:white)}"
    future.score(color)
  end

  def make_a_move! evaluate=:evaluate3
    return nil if win_condition?

    t = moves.map do |move|
      [send(evaluate, move), move]
    end
    max_score = t.map{|e| e.first}.max

    high_moves = t.select{|move| move.first == max_score}

    picked_move = high_moves.shuffle.first[1]
    #puts "#{evaluate.to_s}:: max_score: #{max_score}, picked_move: #{picked_move}"

    make picked_move
    picked_move
  end

  def win_condition?
    return true if king_missing?
    return true if king_win?
  end

  def king_missing?
    !king_present?(:black) ||
    !king_present?(:white)
  end

  def king_win?
    distance_to_win(:black) == 0 ||
    distance_to_win(:white) == 0
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
    b = a.map do |c|
      case c
      when /wc/; 1
      when /ws/; 500
      else; 0
      end
    end.compact.reduce(&:+)
    b = -9999 if b.nil?
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
=begin
    position.each_with_index do |r, ri|
      s = ""
      r.each_with_index do |c, ci|
        s += "[%i,%i:%s]" % [ri, ci, c]
      end
      p s
    end
=end
    position.each_with_index do |r, ri|
      r.each_with_index do |c, ci|
        pieces << Piece.new([ri, ci], piece: c) if c =~ filter
      end
    end
    pieces
  end
end
