require "go_cli/coordinate"
require "csv"

class Order
  def initialize(origin:, destination_x:, destination_y:, order_id: 0)
    @destination = Coordinate.new(x: destination_x, y: destination_y)
    @origin = origin
    @order_id = order_id
  end 

  def create_route
    @route = "- Start at #{@origin.to_string}\n"
    @route << "- Go to (#{@origin.x},#{@destination.y})\n" unless @origin.y == @destination.y
    if @destination.x > @origin.x
      if @destination.y < @origin.y 
        @route << "- Turn left\n"
      else
        @route << "- Turn right\n"
      end
    elsif @destination.x < @origin.x
      if @destination.y < @origin.y
        @route << "- Turn right\n"
      else
        @route << "- Turn left\n"
      end
    end
    @route << "- Go to (#{@destination.x},#{@destination.y})\n" unless @destination.x == @origin.x
    @route << "- Finish at (#{@destination.x},#{@destination.y})"
  end

  def calculate_fare(base_fare:)
    fare = @destination.distance(position: @origin) * base_fare
    @string_fare = "IDR #{fare.to_s.reverse.scan(/(\d*\.\d{1,3}|\d{1,3})/).join('.').reverse}"
  end

  def confirm_order?
    print "Confirm order? (y/n): "
    choice = STDIN.gets.gsub(/\s+/, "")
    case choice.downcase
    when "y"
      @order_id += 1
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

  def add_to_history(filename)
    data = Array.new
    data.push(@order_id, @driver.name, @string_fare, @route)
    CSV.open(filename, "ab") { |csv| csv << data }
  end
end
