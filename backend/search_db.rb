require './model'

term = ARGV[0] or raise "Specify term as first argument"

with_ferret_index do |index|
  query = "lyrics:#{term}"
  index.search_each(query) do |id, score|
    term_vector = index.term_vector(id, :lyrics)
    term_vector.terms.each do |term|
      p term.text
      p term.positions.map { |position|
        term_vector.offsets[position].start..term_vector.offsets[position].end
      }
    end

    doc = index[id]
    puts "- song_id='#{doc[:song_id]}' lyrics='#{doc[:lyrics]}'"
  end
end
