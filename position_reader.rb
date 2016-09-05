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


