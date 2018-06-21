require "go_cli/version"
require "go_cli/coordinate"
require "go_cli/driver"
require "go_cli/user"
require "go_cli/map"
require "go_cli/order"
require "go_cli/file_parser"
require "yaml"

module GoCli
  class App
    include FileParser
    include Map
    include Order
    
    attr_writer :base_fare

    def initialize
      @map_size = 20
      @drivers_amount = 5
      @base_fare = 300
      @drivers = Array.new
      prepare_history_file("history.csv")
      @order_amount = get_order_count
    end

    def starting_app
      puts "Welcome to GO-CLI app v#{GoCli::VERSION}!"

      # initialize data from ARGV
      if ARGV.length > 1      # run with determined map size and user's location
        @map_size = ARGV[0].to_i
        @user = User.new(x: ARGV[1].to_i, y: ARGV[2].to_i)
      elsif ARGV.length > 0  # run with file input
        read_file_input(ARGV[0])
      else                    # run with pre-determined value
        random_coordinate = Coordinate.new(random_size: @map_size)
        @user = User.new(position: random_coordinate)
      end

      # initialize map and drivers
      create_map(@map_size)
      @drivers.empty? ? generate_driver_randomly : @drivers.each { |d| assign_person(person: d) }
      assign_person(person: @user)

      # start menu
      menu
    end

    def read_file_input(filename)
      begin     # File error handling
        input = YAML.load(File.read(filename))
        @map_size = input["map-size"] if input.has_key?("map-size")
      rescue Exception
        puts "File loading failed, please check if the YAML file exists."
        random_coordinate = Coordinate.new(random_size: @map_size)
        @user = User.new(position: random_coordinate)
        return
      end

      if input.has_key?("user")    #check user's position
        input["user"].has_key?("x") ? user_x = input["user"]["x"].to_i : user_x = nil
        input["user"].has_key?("y") ? user_y = input["user"]["y"].to_i : user_y = nil
        @user = User.new(x: user_x, y: user_y)
      else
        random_coordinate = Coordinate.new(random_size: @map_size)
        @user = User.new(position: random_coordinate)
      end

      if input.has_key?("drivers")   # check driver's position
        input["drivers"].each do |driver|
          driver.has_key?("name") ? driver_name = driver["name"] : driver_name = ""
          unless driver["x"] > @map_size || driver["y"] > @map_size
            new_driver = Driver.new(name: driver_name, x: driver["x"], y: driver["y"])
            @drivers.push(new_driver)
          end
        end
      end
    end
    
    def generate_driver_randomly
      forbidden_coordinate = [@user.position]
      random_coordinate = Coordinate.new
      1.upto(@drivers_amount) do    # generate driver's coordinate
        loop do                     # avoid overlapping coordinates
          random_coordinate = Coordinate.new(random_size: @map_size)
          break if forbidden_coordinate.detect { |d| d.x == 
            random_coordinate.x && d.y == random_coordinate.y} == nil
        end
        forbidden_coordinate.push(random_coordinate)

        # assign coordinates
        driver = Driver.new(position: random_coordinate)
        @drivers.push(driver)
        assign_person(person: driver)
      end
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
        draw_map
      when "2"
        create_order
      when "3"
        if @order_amount == 0   # if history is empty
          puts "Please finish at least one trip using GO-RIDE to view history."
          menu
        end
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
      choice[1] = choice[0] if choice[1].nil?
      choice.each do |i|              # destination input's error handling
        unless i.between?(1, @map_size)
          puts "Sorry, but your intended destination is outside our coverage or you mistyped the input.", "We cover areas from (1,1) to (#{@map_size},#{@map_size}).", ""
          create_order
          return
        end
      end
      puts "\n"

      # show details about the order
      destination = Coordinate.new(x: choice[0], y: choice[1])
      new_order(origin: @user.position, destination: destination, order_id: @order_amount + 1)

      driver_id = find_nearest_driver(list: @drivers)
      display_order
      
      # order confirmation
      menu unless confirm_order?   # back to menu if order cancelled
      @order_amount += 1
      position_after_order(driver_id, destination)
      puts "\nYour trip has finished. Thank you for using GO-RIDE service."
    end

    def position_after_order(driver_id, destination)
      update_position(person: @drivers[driver_id - 2], position: destination)
      update_position(person: @user, position: destination)
      @drivers[driver_id - 2].position = @user.position = destination
    end
  end
end
