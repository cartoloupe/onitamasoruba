require_relative 'position_reader'

class Movement
  include PositionReader

  attr_accessor :movement

  def initialize(movement)
    @movement = read movement
  end

  def to_s
    movement.flatten.join
  end

  def flatten
    movement.flatten
  end

  def each_with_index &block
    movement.each_with_index &block
  end

  def reverse
    movement.reverse
  end

  def ==(movement)
    to_s == movement.to_s
  end
end
