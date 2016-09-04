require_relative 'vector'

class Move
  attr_accessor :piece, :vector, :destination

  def initialize(piece, vector)
    @piece = piece
    @vector = vector
    @destination = piece + vector
  end

  def to_s
    "m[%d, %d] to v[%d, %d]" % [piece.x, piece.y, destination.x, destination.y]
  end

  def legal? span
    destination.x >= -1*span && destination.x <= span &&
    destination.y >= -1*span && destination.y <= span
  end
end




