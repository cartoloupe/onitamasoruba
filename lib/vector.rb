class Vector
  attr_reader :x, :y
  def initialize(vector)
    @x = vector[0]
    @y = vector[1]
  end

  def +(vector)
    return Vector.new([
      @x + vector[0],
      @y + vector[1],
    ])
  end

  def [](i)
    return x if i == 0
    return y if i == 1
  end

  def to_s
    "v[%d, %d]" % [x, y]
  end

  def ==(vector)
    x == vector.x && y == vector.y
  end

  def position
    [x + 2, y + 2]
  end

end
