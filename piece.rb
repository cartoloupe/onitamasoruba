class Piece
  attr_reader :x, :y
  def initialize(vector)
    @x = vector[0]
    @y = vector[1]
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
    "p[%d, %d]" % [x, y]
  end

  def ==(vector)
    x == vector.x && y == vector.y
  end

  def position
    [x, y]
  end

end
