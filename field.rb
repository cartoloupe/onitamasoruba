require 'pry'
require_relative 'vector'
require_relative 'move'

module PositionReader
  CELLSIZE = 2
  def read(position)
    position = parse position
    5.times.map do |a|
      5.times.map do |b|
        position.shift
      end
    end
  end

  def read2(position)
    position = parse position
    [
      5.times.map do |a|
        5.times.map do
          |b| position.shift
        end
      end,
      5.times.map do |a|
        5.times.map do |b|
          position.shift
        end
      end
    ]
  end

  private

  def parse(string)
    string.chars.each_slice(CELLSIZE).map(&:join)
  end
end

class Field
  include PositionReader
  attr_accessor :position, :bmovement, :mmovement, :wmovement

  def initialize(stringified_position)
    @position = read stringified_position[0..49]
    @bmovement = read2 stringified_position[50..149]
    @mmovement = read stringified_position[150..199]
    @wmovement = read2 stringified_position[200..299]
  end

  def to_s
    [position, bmovement, mmovement, wmovement].flatten.join
  end

  def score
    nb - nw
  end

  def bpieces
    vectorify position, /bs|bc/
  end

  def bmoves
    moveset1 = vectorify(bmovement.first, /kk/)
    moves = bpieces.flat_map do |piece|
      moveset1.map do |move|
        #STDOUT.puts "piece: %s, move: %s, p2m: %s" % [piece, move, (piece + move)]
        Move.new(piece, move)
      end
    end

    moves.select do |move|
      move.legal? CELLSIZE
    end.reject do |move|
      bpieces.include? move.destination
    end
  end

  def make move
    piece = position[move.piece.position[0]][move.piece.position[1]]
    position[move.piece.position[0]][move.piece.position[1]] = "--"
    position[move.destination.position[0]][move.destination.position[1]] = piece
  end

  private

  def reverse movement
    movement.reverse
  end

  def nb
    position.flatten.count{|c| c =~ /b./}
  end

  def nw
    position.flatten.count{|c| c =~ /w./}
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
end

