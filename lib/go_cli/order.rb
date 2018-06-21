require "go_cli/coordinate"
require "go_cli/file_parser"

module Order
  include FileParser

  def new_order(origin:, destination:, order_id: 0)
    @destination = destination
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
    print "Confirm order? (y/n): "      # get input
    choice = STDIN.gets.gsub(/\s+/, "")
    case choice.downcase
    when "y"                            # complete order
      add_to_history(order_id: @order_id, name: @driver.name, fare: @string_fare, route: @route)
      true
    when "n"                            # cancel order
      false
    else                                # error handling
      puts "Sorry, you can only input 'y' or 'n'."
      confirm_order?
    end
  end

  def find_nearest_driver(list:)        # return chosen driver's id
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
    @driver.instance_variable_get(:@id).to_i
  end

  def display_order
    puts "Driver #{@driver.name}, currently at #{@driver.position.to_string}, will take you to your destination."
    puts "Here is the route you will be taking: \n#{create_route}"
    puts "We estimate this trip will cost you #{calculate_fare(base_fare: @base_fare)}."
  end
end
