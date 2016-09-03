require 'pry'
module PositionReader
  CELLSIZE = 2
  def read(position)
    position = parse position
    5.times.map{|a| 5.times.map{|b| [position.shift]}}
  end

  def read2(position)
    position = parse position
    [
      5.times.map{|a| 5.times.map{|b| [position.shift]}},
      5.times.map{|a| 5.times.map{|b| [position.shift]}}
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
    vectors = []
    position.each_with_index do |r, ri|
      r.each_with_index do |c, ci|
        vectors << [ri, ci] if (c.include?("bc")|| c.include?("bs"))
      end
    end
    vectors.map{|v| v.map{|i| i - 2}}
  end

  def bmoves
    moveset1 = vectorify bmovement.first
    bpieces.map do |piece|
      moveset1.map do |move|
        p "piece: %s, move: %s" % [piece, move]
      end
    end
    binding.pry;2
  end

  private

  def nb
    position.flatten.count{|c| c =~ /b./}
  end

  def nw
    position.flatten.count{|c| c =~ /w./}
  end

  def vectorify movement
    vectors = []
    bmovement.first.each_with_index do |r, ri|
      r.each_with_index do |c, ci|
        vectors << [ri, ci] if c.include? "kk"
      end
    end
    vectors = vectors.map{|v| v.map{|i| i - 2}}
  end
end

