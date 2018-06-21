require "go_cli/coordinate"

module Map
  def create_map(map_size)
    @map_size = map_size
    @map = Array.new
    for i in 0...map_size do
      @map.push(Array.new)
      for j in 0...map_size do
        @map[i].push(".")
      end
    end
  end

  def assign_person(person:, x: nil, y: nil, mark: "?")
    class_name = person.class.name.split('::').last
    if person.nil?
      mark.nil? ? @map[x][y] = "?" : @map[x][y] = mark.to_s
    else
      @user_position = person.position if class_name == "User"
      @map[person.position.x - 1][person.position.y - 1] = person.instance_variable_get(:@id)
    end
  end

  def draw_map
    print "+"
    @map_size.downto(4) { print "-" }
    print "Map--+\n|"
    @map_size.downto(-1) { print " " }
    print "|\n"

    @map.reverse_each do |i|
      print "| "
      i.each { |j| print j }
      print " |\n"
    end

    print "|"
    @map_size.downto(-1) { print " " }
    print "|\n+"
    @map_size.downto(-1) { print "-" }
    puts "+", "Your position at the map is #{@user_position.to_string} indicated by '#{User.user_id}'.", "The rest indicated driver's position."
  end
end
