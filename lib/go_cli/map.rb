require "go_cli/coordinate"

class Map
  attr_accessor :map
  @map_size
  @user_position

  def initialize(map_size)
    @map_size = map_size
    @map = Array.new
    for i in 0...map_size do
      @map.push(Array.new)
      for j in 0...map_size do
        @map[i].push(".")
      end
    end
  end

  def assign_person(person: nil, x: nil, y: nil, mark: nil)
    if person.nil?
      mark.nil? ? @map[x][y] = "?" : @map[x][y] = mark.to_s
    else
      @map[person.position.x - 1][person.position.y - 1] = person.instance_variable_get(:@id)
    end

    if person.class.name.split('::').last == "User"
      @user_position = person.position
    end
  end

  def draw_map
      print "\n/"
      @map_size.downto(2) { print "-" }
      print "Map\\\n|"
      @map_size.downto(-1) { print " " }
      print "|\n"

      @map.reverse_each do |i|
        print "| "
        i.each { |j| print j }
        print " |\n"
      end

      print "|"
      @map_size.downto(-1) { print " " }
      print "|\n\\"
      @map_size.downto(-1) { print "-" }
      print "/  Your position at the map is "
      @user_position.print_info
      puts " indicated by '#{User.user_id}'. The numbers indicated driver's position."
    end
end
