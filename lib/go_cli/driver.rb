require 'go_cli/person'
require 'go_cli/coordinate'

class Driver < Person
  @@driver_count = 0

  def initialize(name: "", position:, x: nil, y: nil)
    super(position: position, x: x, y: y)
    @@driver_count += 1
    @id = @@driver_count.to_s
    if name == ""
      @name = "No. #{@id}"
    end
  end

  def print_info
    puts "Driver #{@name} is positioned at #{@position.print_info}"
  end

end
