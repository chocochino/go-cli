require 'go_cli/coordinate'

class Person
    attr_reader :name
    attr_accessor :position

    def initialize(name: "", position: nil, x: nil, y: nil)
        @name = name
        change_position(position: position, x: x, y: y)
    end

    def change_position(position: nil, x: nil, y: nil)
        if position.nil?
            if x.nil? 
                x = 1
            end

            if y.nil?
                y = 1
            end

            @position = Coordinate.new(x: x, y: y)

        else
            @position = Coordinate.new(x: position.x, y:position.y)
        end
    end

    def print_info
        print "#{@name} is at "
        @position.print_info
    end

end
