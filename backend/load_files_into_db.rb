require './model.rb'

song_names_path = File.expand_path('../../song_names/', __FILE__)
Dir.entries(song_names_path).each do |artist_id|
  next if artist_id == '.' || artist_id == '..'
  File.open(File.join(song_names_path, artist_id)) do |file|
    file.each_line do |line|
      song_id, song_name = line.split(' ')

      unless Song.first(:id => song_id)
        song = Song.new({
          :id => song_id,
          :name => song_name,
          :created_at => DateTime.now,
        })
        song.save!
      end
    end
  end
end
