require './model'
require './analyzer'
require 'json'

$stem_analyzer = MyAnalyzer.new(true)
$non_stem_analyzer = MyAnalyzer.new(false)
$stemmed_to_word_to_count = {}
$stemmed_to_count = {}

def add_unlabeled_song(
    index, song_id, song_name, artist_id, artist_name, lyrics)
  metadata = {}
  metadata[:song_name] = song_name
  metadata[:artist_name] = artist_name
  to_add = {
    :song_id         => song_id,
    :artist_id       => artist_id,
    :lyrics          => lyrics,
    :has_start_times => 0,
    :metadata        => JSON.dump(metadata),
  }
  index << to_add

  lyrics = lyrics.split("\n").join(' ')
  non_stem_token_stream = $non_stem_analyzer.token_stream(:lyrics, lyrics)
  while non_stem_token = non_stem_token_stream.next
    non_stemmed = non_stem_token.text.force_encoding('UTF-8')
    stem_token_stream = $stem_analyzer.token_stream(:lyrics, non_stemmed)
    stem_token = stem_token_stream.next
    if stem_token
      stemmed = stem_token.text.force_encoding('UTF-8')
      $stemmed_to_word_to_count[stemmed] ||= {}
      $stemmed_to_word_to_count[stemmed][non_stemmed] ||= 0
      $stemmed_to_word_to_count[stemmed][non_stemmed] += 1
      $stemmed_to_count[stemmed] ||= 0
      $stemmed_to_count[stemmed] += 1
    end
  end
end

artist_names_path = File.expand_path('../../artist_names/', __FILE__)
song_names_path = File.expand_path('../../song_names/', __FILE__)
song_lyrics_path = File.expand_path('../../song_lyrics/', __FILE__)

artist_id_to_name = {}
Dir.foreach(artist_names_path) do |artist_id|
  next if artist_id == '.' || artist_id == '..'
  File.open(File.join(artist_names_path, artist_id)) do |file|
    file.each_line do |line|
      if line_match = line.match(/^:: (.*)$/)
        content = line_match[1]
        artist_name, artist_link = content.split("\t")
        if artist_id_match = artist_link.match(/([0-9]+)$/)
          artist_id = artist_id_match[1]
          artist_id_to_name[artist_id] = artist_name
        end
      end
    end
  end
end

puts "Reading song_id -> song_name mappings..."
song_id_to_song_name = {}
Dir.entries(song_names_path).each do |artist_id|
  next if artist_id == '.' || artist_id == '..'
  File.open(File.join(song_names_path, artist_id)) do |file|
    puts "Checking songs in #{artist_id}..."
    file.each_line do |line|
      if line_match = line.match(/^:: Letras de (.*) - (.*)$/)
        content = line_match[2]
        song_name, song_link = content.split("\t")
        if song_id_match = song_link.match(/([0-9]+)$/)
          song_id = song_id_match[1].to_i
          song_id_to_song_name[song_id] = song_name
        end
      end
    end
  end
end

puts 'Getting existing list in index...'
existing_song_ids = {}
with_ferret_index do |index|
  index.each do |doc|
    song_id = doc[:song_id]
    if song_id
      existing_song_ids[song_id] = true
    end
  end
end

puts 'Adding to index...'
with_ferret_index do |index|
  Dir.entries(song_lyrics_path).each do |artist_id|
    next if artist_id == '.' || artist_id == '..'
    Dir.entries(File.join(song_lyrics_path, artist_id)).each do |song_id|
      next if song_id == '.' || song_id == '..'
      unless existing_song_ids[song_id]
        song_name = song_id_to_song_name[song_id.to_i]
        if song_name
          puts "Inserting song #{song_id}..."
          File.open(File.join(song_lyrics_path, artist_id, song_id)) do |file|
            lyrics = file.read
            artist_name = artist_id_to_name[artist_id]
            add_unlabeled_song(
              index, song_id, song_name, artist_id, artist_name, lyrics)
          end
        end
      end
    end
  end
end

puts 'Sorting best_words...'
best_stemmed = $stemmed_to_count.keys.sort_by { |stemmed|
  -$stemmed_to_count[stemmed]
}[0..100]
BestWord.all.destroy!
best_words = best_stemmed.map { |stemmed|
  word_to_count = $stemmed_to_word_to_count[stemmed]
  best_word = word_to_count.keys.sort_by { |word| -word_to_count[word] }.first
  BestWord.create({
    :word => best_word,
    :count => word_to_count[best_word],
    :created_at => DateTime.now,
  })
}
