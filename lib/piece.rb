class Piece
  attr_reader :x, :y, :piece

  def initialize(vector, piece: piece)
    @x = vector[0]
    @y = vector[1]
    @piece = piece
  end

  def +(vector)
    return Piece.new([
      @x + vector[0],
      @y + vector[1],
    ])
  end

  def [](i)
    return x if i == 0
    return y if i == 1
  end

  def to_s
    "p-#{piece}[%d, %d]" % [x, y]
  end

  def ==(vector)
    x == vector.x && y == vector.y
  end

  def position
    [x, y]
  end
  alias_method :coordinates, :position

end
