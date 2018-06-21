require "go_cli/coordinate"

module Map
  EMPTY_COORDINATE = "."

  def create_map(map_size)
    @map_size = map_size
    @map = Array.new
    for i in 0...map_size do
      @map.push(Array.new)
      for j in 0...map_size do
        @map[i].push(Map::EMPTY_COORDINATE)
      end
    end
  end

  def assign_person(person:, x: nil, y: nil, mark: nil)
    class_name = person.class.name.split('::').last
    unless x.nil? && y.nil?
      mark.nil? ? @map[y - 1][x - 1] = "?" : @map[y - 1][x - 1] = mark.to_s
    else
      @user_position = person.position if class_name == "User"
      if mark.nil?
        @map[person.position.y - 1][person.position.x - 1] = person.instance_variable_get(:@id)
      else
        @map[person.position.y - 1][person.position.x - 1] = mark
      end
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

  def update_position(person:, position: nil, x: nil, y: nil)
    unless position.nil?
      x = position.x
      y = position.y
    end

    # empty original place
    assign_person(person: person, mark: Map::EMPTY_COORDINATE)

    # update map
    person.position.x = x
    person.position.y = y
    assign_person(person: person)
  end
end
