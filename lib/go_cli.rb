require "go_cli/version"
require "go_cli/coordinate"
require "go_cli/driver"
require "go_cli/user"
require "go_cli/map"

module GoCli
  class App
    @@map_size = 20
    @@drivers_amount = 5

    def starting_app
      puts "Welcome to GO-CLI app!"

      if ARGV.length > 1
        @@map_size = ARGV[0].to_i
        @user = User.new(x: ARGV[1].to_i, y: ARGV[2].to_i)
      #elsif ARGV.length > 0
      else
        random_coordinate = Coordinate.new(random_size: @@map_size)
        @user = User.new(position: random_coordinate)
      end

      @map = Map.new(@@map_size)
      @map.assign_person(person: @user)
      generate_driver_randomly

      menu
    end

    def generate_driver_randomly
      @drivers = Array.new
      random_coordinate = Coordinate.new
      1.upto(@@drivers_amount) do
        loop do
          random_coordinate = Coordinate.new(random_size: @@map_size)
          break unless random_coordinate == @user.position
        end
        driver = Driver.new(position: random_coordinate)
        @drivers.push(driver)
        @map.assign_person(person: driver)
      end
    end

    def menu
      puts "\nWhat do you want to do?", "[1] Show map", "[2] Order GO-RIDE", "[3] View history", "[4] Exit program"
      print "Your choice (input correlating number): "
      choice = STDIN.gets.chomp.tr('[]()', '')

      case choice
      when "1"
        @map.draw_map
      when "2"
        puts "\nThis option will be developed shortly."
      when "3"
        view_history
      when "4"
        puts "\nThank you for using GO-CLI, see you next time."
        exit(true)
      else
        puts "Sorry, please input number '1', '2', '3', or '4' only."
      end
      menu
    end

    def view_history
      puts "\nPlease finish at least one trip using GO-RIDE to view history."
      menu
    end
  end
end
