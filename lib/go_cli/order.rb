require "go_cli/coordinate"

class Order
  attr_reader :destination

  def initialize(origin:, destination_x:, destination_y:)
    @destination = Coordinate.new(x: destination_x, y: destination_y)
    @origin = origin
  end 

  def show_route
    puts "Here is the route you will be taking:", "- Start at #{@origin.to_string}"
    puts "- Go to (#{@origin.x},#{@destination.y})" unless @origin.y == @destination.y
    if @destination.x > @origin.x
      if @destination.y < @origin.y 
        puts "- Turn left"
      else
        puts "- Turn right"
      end
    elsif @destination.x < @origin.x
      if @destination.y < @origin.y
        puts "- Turn right"
      else
        puts "- Turn left"
      end
    end
    puts "- Go to (#{@destination.x},#{@destination.y})" unless @destination.x == @origin.x
    puts "- Finish at (#{@destination.x},#{@destination.y})"
  end

  def calculate_fare(base_fare:)
    fare = @destination.distance(position: @origin) * base_fare
    string_fare = fare.to_s.reverse.scan(/(\d*\.\d{1,3}|\d{1,3})/).join('.').reverse
    puts "We estimate this trip will cost you Rp #{string_fare}."
  end

  def confirm_order?
    puts "Confirm order? (y/n)"
    choice = STDIN.gets.gsub(/\s+/, "")
    case choice.downcase
    when "y"
      true
    when "n"
      false
    else
      puts "Sorry, you can only input 'y' or 'n'."
      confirm_order?
    end
  end

  def find_nearest_driver(list:)
    @driver = list[0]
    min_distance = @driver.position.distance(position: @origin)
    list.shift
    list.each do |d|
      temp = d.position.distance(position: @origin)
      if temp < min_distance
        @driver = d
        min_distance = temp
      end
    end
    @driver
  end
end
