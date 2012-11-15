backend_dir = File.expand_path(File.dirname(__FILE__))
require "#{backend_dir}/model.rb"

artist_names_path = File.expand_path('../../artist_names/', __FILE__)
song_names_path = File.expand_path('../../song_names/', __FILE__)
song_lyrics_path = File.expand_path('../../song_lyrics/', __FILE__)

Dir.foreach(artist_names_path) do |artist_id|
  next if artist_id == '.' || artist_id == '..'
  File.open(File.join(artist_names_path, artist_id)) do |file|
    file.each_line do |line|
      if line_match = line.match(/^:: (.*)$/)
        content = line_match[1]
        artist_name, artist_link = content.split("\t")
        if artist_id_match = artist_link.match(/([0-9]+)$/)
          artist_id = artist_id_match[1].to_i
          unless Artist.first(:id => artist_id)
            p [artist_id]
            artist = Artist.new({
              :id => artist_id,
              :name => artist_name,
              :created_at => DateTime.now,
            })
            artist.save rescue raise artist.errors.inspect
          end
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

Dir.entries(song_lyrics_path).each do |artist_id|
  next if artist_id == '.' || artist_id == '..'
  Dir.entries(File.join(song_lyrics_path, artist_id)).each do |song_id|
    next if song_id == '.' || song_id == '..'
    unless Song.count(:id => song_id) > 0
      song_name = song_id_to_song_name[song_id.to_i]
      if song_name
        puts "Inserting song #{song_id}..."
        File.open(File.join(song_lyrics_path, artist_id, song_id)) do |file|
          lyrics = file.read
          song = Song.new({
            :artist_id => artist_id,
            :id => song_id,
            :name => song_name,
            :lyrics => lyrics,
            :created_at => DateTime.now,
          })
          song.save rescue raise song.errors.inspect

          #file.each_line do |line|
          #  lyric = line.strip
          #  song_line = SongLine.new({
          #    :artist_id => artist_id,
          #    :song_id => song_id,
          #    :lyric => lyric,
          #    :created_at => DateTime.now,
          #  })
          #  song_line.save rescue raise song_line.errors.inspect
          #end
        end
      end
    end
  end
end
