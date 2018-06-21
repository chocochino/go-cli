require 'csv'

module FileParser
  def prepare_history_file(filename)
    @filename = filename
    CSV.open(@filename, "wb", write_headers: true) { |csv| csv << %w(ID Driver Fare Route)} unless File.exist?(@filename)
  end

  def get_order_count
    CSV.foreach(@filename, headers: true).count
  end

  def add_to_history(order_id:, name:, fare:, route:)
    data = Array.new
    data.push(order_id, name, fare, route)
    CSV.open(@filename, "ab") { |csv| csv << data }
  end

  def view_history
    puts "Here are your trip history:"
    CSV.open(@filename, headers: true) do |entry|
      entry.each do |history|
        route = history['Route'].split("\n")
        puts "#{history['ID']}. Driver's name: #{history['Driver']}", "   Fare: #{history['Fare']}", "   Route: #{route[0]}"
        1.upto(route.length-1) { |i| puts "          #{route[i]}"}
        puts ""
      end
    end
  end
end
