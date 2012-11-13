backend_dir = File.expand_path(File.dirname(__FILE__))
require "#{backend_dir}/model.rb"

artist_names_path = File.expand_path('../../artist_names/', __FILE__)
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
            artist.save or raise artist.errors.inspect
          end
        end
      end
    end
  end
end

song_names_path = File.expand_path('../../song_names/', __FILE__)
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
          unless Song.first(:id => song_id)
            p [artist_id, song_id]
            song = Song.new({
              :artist_id => artist_id,
              :id => song_id,
              :name => song_name,
              :created_at => DateTime.now,
            })
            song.save or raise song.errors.inspect
          end
        end
      end
    end
  end
end

if false
song_lyrics_path = File.expand_path('../../song_lyrics/', __FILE__)
Dir.entries(song_lyrics_path).each do |artist_id|
  next if artist_id == '.' || artist_id == '..'
  Dir.entries(File.join(song_lyrics_path, artist_id)).each do |song_id|
    next if song_id == '.' || song_id == '..'
    unless SongLine.count(:song_id => song_id) > 0
      File.open(File.join(song_lyrics_path, artist_id, song_id)) do |file|
        file.each_line do |line|
          lyric = line.strip
          song_line = SongLine.new({
            :artist_id => artist_id,
            :song_id => song_id,
            :lyric => lyric,
            :created_at => DateTime.now,
          })
          song_line.save
        end
      end
    end
  end
end
end
