require_relative 'vector'
require_relative 'move'
require_relative 'piece'
require_relative 'position_reader'
require_relative 'movement'
require_relative 'logger_helper'

class Field
  include PositionReader
  include LoggerHelper

  STARTING_BOARD=
    %w(
      wc wc ws wc wc
      -- -- -- -- --
      -- -- -- -- --
      -- -- -- -- --
      bc bc bs bc bc
    )
  MOVEMENT1=
    %w(
      -- -- -- -- --
      -- kk -- kk --
      kk -- cs -- kk
      -- -- -- -- --
      -- -- -- -- --
    )
  MOVEMENT2=
    %w(
      -- -- -- -- --
      -- -- kk -- --
      -- kk cs kk --
      -- -- kk -- --
      -- -- -- -- --
    )
  MOVEMENT3=
    %w(
      -- -- -- -- --
      -- kk kk kk --
      -- -- cs -- --
      -- -- -- -- --
      -- -- -- -- --
    )
  MOVEMENT4=
    %w(
      -- -- kk -- --
      -- -- kk -- --
      -- -- cs -- --
      -- -- -- -- --
      -- -- -- -- --
    )
  BMOVEMENT= [MOVEMENT3, MOVEMENT4]
  MMOVEMENT= [MOVEMENT3]
  WMOVEMENT= [MOVEMENT4, MOVEMENT3]
  MOVEMENTS= [BMOVEMENT, MMOVEMENT, WMOVEMENT]
  TURN=0
  STRINGIFIED_POSITION= [STARTING_BOARD, MOVEMENTS, TURN].flatten.join

  def self.default_starting_position
    STRINGIFIED_POSITION
  end


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
    #log "moves.to_s:"
    #log moves.map(&:to_s)
    grouped =
      moves
      .map{|move|
        [move.piece.coordinates, move.destination.coordinates]
      }
      .group_by{|coordinates, _| coordinates}

    grouped.keys.each{|k|
      grouped[k] = grouped[k].map{|src,dst| dst}
    }

    #log "valid_moves:"
    #log grouped
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

    #log "moveset1"
    #log moveset1

    moves = pieces.flat_map do |piece|
      moveset1.map do |move|
        Move.new(piece, move, movement.first)
      end
    end

    #log "all moves:"
    #log moves.map(&:to_s)
    t = moves
    t = t.select do |move|
      move.legal? CELLSIZE
    end
    #log "pieces:"
    #log pieces
    t = t.reject do |move|
      pieces.include? move.destination
    end

    #log "filtered moves:"
    #log t.map(&:to_s)
    t
  end

  def make piece_x, piece_y, destination_x, destination_y, movement_idx
    piece = position[piece_x][piece_y]
            position[piece_x][piece_y] = "--"
            position[destination_x][destination_y] = piece


    Rails.logger.info "making a move"
    case turn
    when 0
      movement = bmovement[movement_idx.to_i]
    when 1
      movement = wmovement[movement_idx.to_i]
    end

    update_movements Movement.new(movement.to_s)
    Rails.logger.debug "222222222222"
    Rails.logger.debug print_movements
    Rails.logger.debug "222222222222"
    update_turn
  end

  def update_movements movement
    Rails.logger.debug "update_movements"
    Rails.logger.debug "------------"
    Rails.logger.debug print_movements
    Rails.logger.debug "------------"
    Rails.logger.debug "turn: #{turn}"
    Rails.logger.debug "------------"
    case turn
    when 0
      idx = @bmovement.index(movement)
      @bmovement.delete_at(idx) unless idx.nil?
      @bmovement << Movement.new(mmovement.to_s)
      Rails.logger.info "bmovement now: #{bmovement.map(&:to_s)}"
    when 1
      idx = @wmovement.index(movement)
      @wmovement.delete_at(idx) unless idx.nil?
      @wmovement << Movement.new(mmovement.to_s)
      Rails.logger.info "wmovement now: #{wmovement.map(&:to_s)}"
    end
    @mmovement = movement
  end

  def print_movements
    [
      self.bmovement.map(&:to_s),
      self.mmovement,
      self.wmovement.map(&:to_s),
    ].join("\n")
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
    future.make *move.to_splat
    future.score(color)
  end

  def evaluate2 move
    future = Field.new(to_s)
    future.make *move.to_splat
    future.make_a_move! :evaluate1
    future.score(color)
  end

  def evaluate3 move
    future = Field.new(to_s)
    future.make *move.to_splat
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

    make *picked_move.to_splat
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
        vectors << Vector.new([ri, ci]) if c =~ filter
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
