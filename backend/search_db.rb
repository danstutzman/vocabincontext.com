require './model'

term = ARGV[0] or raise "Specify term as first argument"

with_ferret_index do |index|
  index.search_each("lyrics:#{term}") do |id, score|
    doc = index[id]
    puts "song_id='#{doc[:song_id]}' lyrics='#{doc[:lyrics]}'"
  end
end
