require './model'

term = ARGV[0] or raise "Specify term as first argument"

with_ferret_index do |index|
  query = "lyrics:#{term}"
  index.search_each(query) do |id, score|
    p index.term_vector(id, :lyrics)
    doc = index[id]
    puts "song_id='#{doc[:song_id]}' lyrics='#{doc[:lyrics]}'"
  end
end
