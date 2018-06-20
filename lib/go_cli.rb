require "go_cli/version"
require "go_cli/coordinate"
require "go_cli/driver"
require "go_cli/user"
require "go_cli/map"
require "go_cli/order"
require "csv"

module GoCli
  class App
    attr_writer :base_fare

    def initialize
      @map_size = 20
      @drivers_amount = 5
      @base_fare = 300
      @drivers = Array.new
      @history_filename = "history.csv"
      create_history_file unless File.exist?(@history_filename)
      @order_amount = CSV.foreach(@history_filename, headers: true).count
    end

    def starting_app
      puts "Welcome to GO-CLI app!"

      # initialize data from ARGV
      if ARGV.length > 1      # run with determined map size and user's location
        @map_size = ARGV[0].to_i
        @user = User.new(x: ARGV[1].to_i, y: ARGV[2].to_i)
      #elsif ARGV.length > 0  # run with file input
      else                    # run with pre-determined value
        random_coordinate = Coordinate.new(random_size: @map_size)
        @user = User.new(position: random_coordinate)
      end

      # initialize map and drivers
      @map = Map.new(@map_size)
      @map.assign_person(person: @user)
      generate_driver_randomly

      # start menu
      menu
    end

    def generate_driver_randomly
      forbidden_coordinate = [@user.position]
      random_coordinate = Coordinate.new
      1.upto(@drivers_amount) do
        loop do
          random_coordinate = Coordinate.new(random_size: @map_size)
          break if forbidden_coordinate.detect { |d| d.x == 
            random_coordinate.x && d.y == random_coordinate.y} == nil
        end
        forbidden_coordinate.push(random_coordinate)
        driver = Driver.new(position: random_coordinate)
        @drivers.push(driver)
        @map.assign_person(person: driver)
      end
    end

    def create_history_file
      CSV.open(@history_filename, "wb", write_headers: true) { |csv| csv << %w(ID Driver Fare Route)}
    end

    def menu
      # receive user's choice
      puts "\nWhat do you want to do?", "[1] Show map", "[2] Order GO-RIDE", "[3] View history", "[4] Exit program"
      print "Your choice (input correlating number): "
      choice = STDIN.gets.chomp.tr('[]()', '')
      print "\n"

      # go to selected choice
      case choice
      when "1"
        @map.draw_map
      when "2"
        create_order
      when "3"
        view_history
      when "4"
        puts "Thank you for using GO-CLI, see you next time."
        exit(true)
      else      # input choice error handling
        puts "Sorry, please input number '1', '2', '3', or '4' only."
      end

      # call menu again after choices finish running
      menu
    end

    def create_order
      # user input destination
      puts "Where do you want to go?"
      print "Input the coordinate (x,y) separated with comma (,) or 'N' to cancel order: "
      choice = STDIN.gets.chomp
      menu if choice.downcase == "n"  # back to menu if cancel inputting
      choice = choice.tr('[]()', '').gsub(/\s+/, "").split(",").map(&:to_i)
      choice.each do |i|              # destination input's error handling
        unless i.between?(1, @map_size)
          puts "Sorry, but your intended destination is outside our coverage or you mistyped the input.", "We cover areas from (1,1) to (#{@map_size},#{@map_size}).", ""
          create_order
        end
      end
      puts "\n"

      # show details about the order
      order = Order.new(origin: @user.position, destination_x: choice[0], destination_y: choice[1], order_id: @order_amount)
      driver = order.find_nearest_driver(list: @drivers)
      puts "Driver #{driver.name} will take you to your destination."
      puts "Here is the route you will be taking: \n#{order.create_route}"
      puts "We estimate this trip will cost you #{order.calculate_fare(base_fare: @base_fare)}."
      
      # order confirmation
      menu unless order.confirm_order?   # back to menu if order cancelled
      order.add_to_history(@history_filename)
      @order_amount += 1
      puts "\nYour trip has finished. Thank you for using GO-RIDE service."
    end

    def view_history
      if @order_amount == 0
        puts "Please finish at least one trip using GO-RIDE to view history."
        menu
      end
      puts "Here are your trip history:"
      CSV.open(@history_filename, headers: true) do |entry|
        entry.each do |history|
          route = history['Route'].split("\n")
          puts "#{history['ID']}. Driver's name: #{history['Driver']}", "   Fare: #{history['Fare']}", "   Route: #{route[0]}"
          1.upto(route.length-1) { |i| puts "          #{route[i]}"}
          puts ""
        end
      end
    end
  end
end
