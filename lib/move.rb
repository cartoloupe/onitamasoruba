require_relative 'vector'

class Move
  attr_accessor :piece, :vector, :destination, :movement

  def initialize(piece, vector, movement)
    @piece = piece
    @vector = vector
    @destination = piece + vector
    @movement = movement
  end

  def to_s
    "p-#{piece.piece}[%d, %d] to s[%d, %d]" % [piece.x, piece.y, destination.x, destination.y]
  end

  def to_notation
    "m-#{piece.piece}[%d, %d]-[%d, %d]" % [piece.x, piece.y, destination.x, destination.y]
  end

  def to_splat
    [piece.x, piece.y, destination.x, destination.y, movement]
  end

  def legal? span
    destination.x >= 0 && destination.x <= 2 * span &&
    destination.y >= 0 && destination.y <= 2 * span
  end
end




