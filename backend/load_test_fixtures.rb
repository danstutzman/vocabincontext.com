backend_dir = File.expand_path(File.dirname(__FILE__))
require "#{backend_dir}/model.rb"

[100, 200].each do |artist_id|
  unless Artist.first(:id => artist_id)
    artist = Artist.new({
      :id => artist_id,
      :name => "artist#{artist_id}",
      :created_at => DateTime.now,
    })
    artist.save rescue raise artist.errors.inspect
  end

  [10, 20].each do |song_id_addition|
    song_id = artist_id + song_id_addition
    unless Song.first(:id => song_id)
      song = Song.new({
        :artist_id => artist_id,
        :id => song_id,
        :name => "song#{song_id}",
        :lyrics => "lyrics for song#{song_id}",
        :created_at => DateTime.now,
      })
      song.save rescue raise song.errors.inspect
     end

     [1, 2].each do |song_line_id_addition|
       song_line_id = song_id + song_line_id_addition
       song_line = SongLine.new({
         :artist_id => artist_id,
         :song_id => song_id,
         :lyric => "lyric#{song_line_id}",
         :created_at => DateTime.now,
       })
       song_line.save rescue raise song_line.errors.inspect
     end
  end
end
