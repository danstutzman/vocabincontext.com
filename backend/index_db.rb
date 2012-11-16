require './model'
require './analyzer'
require 'json'

stem_analyzer = MyAnalyzer.new(true)
non_stem_analyzer = MyAnalyzer.new(false)
stemmed_to_word_to_count = {}
stemmed_to_count = {}

puts 'Opening index...'
with_ferret_index do |index|
  puts 'Listing songs...'
  Song.all.each do |song|
    puts song.id
    to_add = {
      :song_id => song.id,
      :name    => song.name,
      :lyrics  => song.lyrics,
    }
    index << to_add

    lyrics = song.lyrics.split("\n").join(' ')
    non_stem_token_stream = non_stem_analyzer.token_stream(:lyrics, lyrics)
    while non_stem_token = non_stem_token_stream.next
      non_stemmed = non_stem_token.text.force_encoding('UTF-8')
      stem_token_stream = stem_analyzer.token_stream(:lyrics, non_stemmed)
      stem_token = stem_token_stream.next
      if stem_token
        stemmed = stem_token.text.force_encoding('UTF-8')
        stemmed_to_word_to_count[stemmed] ||= {}
        stemmed_to_word_to_count[stemmed][non_stemmed] ||= 0
        stemmed_to_word_to_count[stemmed][non_stemmed] += 1
        stemmed_to_count[stemmed] ||= 0
        stemmed_to_count[stemmed] += 1
      end
    end
  end
end

puts 'Sorting best_words...'
best_stemmed =
  stemmed_to_count.keys.sort_by { |stemmed| -stemmed_to_count[stemmed] }[0..100]
best_words = best_stemmed.map { |stemmed|
  word_to_count = stemmed_to_word_to_count[stemmed]
  best_word = word_to_count.keys.sort_by { |word| -word_to_count[word] }.first
  { :word => best_word, :count => word_to_count[best_word] }
}

puts 'Dumping out best_words.json...'
File.open('best_words.json', 'w') do |file|
  file.write JSON.dump(best_words)
end
