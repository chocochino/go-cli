require 'go_cli/person'
require 'go_cli/coordinate'

class Driver < Person
  @@driver_count = 0

  def initialize(name: "", position: nil, x: nil, y: nil)
    super(position: position, x: x, y: y)
    @@driver_count += 1
    @id = @@driver_count.to_s
    if name == ""
      @name = "No. " + @id.to_s
    end
  end

  def print_info
    print "Driver #{@name} is positioned at "
    @position.print_info
    print "\n"
  end

end
