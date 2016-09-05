require_relative 'vector'

class Move
  attr_accessor :piece, :vector, :destination

  def initialize(piece, vector)
    @piece = piece
    @vector = vector
    @destination = piece + vector
  end

  def to_s
    "p[%d, %d] to s[%d, %d]" % [piece.x, piece.y, destination.x, destination.y]
  end

  def to_str
    "p[%d, %d] to s[%d, %d]" % [piece.x, piece.y, destination.x, destination.y]
  end

  def legal? span
    destination.x >= 0 && destination.x <= 2 * span &&
    destination.y >= 0 && destination.y <= 2 * span
  end
end




