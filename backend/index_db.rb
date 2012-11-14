require './model'

with_ferret_index do |index|
  Song.all.each do |song|
    to_add = {
      :song_id => song.id,
      :name    => song.name,
      :lyrics  => song.lyrics,
    }
    p to_add
    index << to_add
  end
end
