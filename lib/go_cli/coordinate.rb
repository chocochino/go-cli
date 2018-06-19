class Coordinate
  attr_accessor :x, :y

  def initialize(x: nil, y: nil, random_size: nil)
    if random_size.nil?
      x.nil? ? @x = 1 : @x = x
      y.nil? ? @y = 1 : @y = y
    else
      random_coordinate(random_size) 
    end
  end

  def random_coordinate(size)
    @x = rand(1..size)
    @y = rand(1..size)
  end


  def print_info
    print "(#{@x},#{@y})"
  end

end
