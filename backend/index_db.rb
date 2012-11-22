require './model'
require './analyzer'
require 'json'

if false
  best_words = JSON.load(File.read('best_words.json'))
  best_words.each do |best_word|
    p best_word
    BestWord.create({
      :word => best_word['word'],
      :count => best_word['count'],
      :created_at => DateTime.now,
    })
  end
end

stem_analyzer = MyAnalyzer.new(true)
non_stem_analyzer = MyAnalyzer.new(false)
stemmed_to_word_to_count = {}
stemmed_to_count = {}

puts 'Opening index...'
with_ferret_index do |index|
  puts 'Listing songs...'
  Song.all.each do |song|
    puts song.id

    metadata = {}
    metadata[:song_id] = song.id
    metadata[:song_name] = song.name
    if song.artist && song.artist.name
      metadata[:artist_name] = song.artist.name
    end
    if (song.start_times_json || '[]') != '[]'
      metadata[:start_times] = JSON.load(song.start_times_json)
    end
    if song.youtube_video_id
      metadata[:youtube_video_id] = song.youtube_video_id
    end

    to_add = {
      :lyrics          => song.lyrics,
      :has_start_times => ((song.start_times_json || '[]') != '[]') ? 1 : 0,
      :metadata        => JSON.dump(metadata),
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
  BestWord.create({
    :word => best_word,
    :count => word_to_count[best_word],
    :created_at => DateTime.now,
  })
}
