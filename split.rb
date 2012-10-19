require 'json'

song = ARGV[0] or raise "First param should be song name"

lines = nil
File.open("media/lyrics_txt/#{song}.txt") do |file|
  file.readline # ignore first line
  lines = file.readlines
end

def millis_to_msh(millis) # msh = minutes.seconds.hundredths
  minutes = millis / 60000
  seconds = (millis / 1000) % 60
  hundredths = (millis % 1000) / 10
  sprintf('%02d.%02d.%02d', minutes, seconds, hundredths)
end

split_times = []
split_time_to_lyric = {}
lines.each { |line|
  if match = line.match(/^([0-9]+)\s+(.*)$/)
    begin_millis = match[1].to_i
    lyric = match[2]
    msh = millis_to_msh(begin_millis)
    split_times.push(msh)
    split_time_to_lyric[msh] = lyric
  end
}

mp3splt =
  if File.exists?('/usr/bin/mp3splt')
    '/usr/bin/mp3splt'
  elsif File.exists?('/usr/local/bin/mp3splt')
    '/usr/local/bin/mp3splt'
  else
    raise "Don't know where to find mp3splt"
  end

command =
  "#{mp3splt} -Q -d media/excerpts -o #{song}_@m@s@h media/whole_songs/#{song}.mp3 #{split_times.join(' ')} 2>&1"
puts command
system(command)

to_json = []
split_time_to_lyric.each do |split_time, lyric|
  split_time = split_time.gsub('.', '')
  old_filename = "media/excerpts/#{song}_#{split_time}.mp3"
  if lyric.match(/^#/)
    command = "/bin/rm #{old_filename}"
  else
    lyric_escaped = lyric.gsub(/[^A-Za-z]/, '_')
    new_filename = "media/excerpts/#{song}_#{split_time}_#{lyric_escaped}.mp3"
    command = "/bin/mv #{old_filename} #{new_filename}"
    to_json.push({
      :id => split_time,
      :filename => new_filename,
      :lyric => lyric
    })
  end
  puts command
  system(command)
end

File.open("media/lyrics_json/#{song}.json", 'w') do |file|
  file.write(JSON.generate(to_json))
end
