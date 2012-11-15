require './model'

with_ferret_index do |index|
  Song.all.each do |song|
    puts song.id
    to_add = {
      :song_id => song.id,
      :name    => song.name,
      :lyrics  => song.lyrics,
    }
    index << to_add
  end
end
