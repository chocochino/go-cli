require 'go_cli/person'

class User < Person
  @@user_id = "u"

  def initialize(position: nil, x: nil, y: nil)
    super(name: "User", position: position, x: x, y: y)
    @id = @@user_id
  end

  def self.user_id
    @@user_id
  end
end
