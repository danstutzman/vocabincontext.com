#!/usr/bin/ruby
splits = [
  [ 500, 1500],
  [1500, 3000],
]

def millis_to_msh(millis) # msh = minutes.seconds.hundredths
  minutes = millis / 60000
  seconds = (millis / 1000) % 60
  hundredths = (millis % 1000) / 10
  sprintf('%d.%02d.%02d', minutes, seconds, hundredths)
end

begin_millis = splits.map { |(begin_millis, end_millis)|
  begin_millis
} + [splits.last[1]]
pairs = begin_millis.map do |begin_millis|
  millis_to_msh(begin_millis)
end

mp3splt =
  if File.exists?('/usr/bin/mp3splt')
    '/usr/bin/mp3splt'
  elsif File.exists?('/usr/local/bin/mp3splt')
    '/usr/local/bin/mp3splt'
  else
    raise "Don't know where to find mp3splt"
  end

command =
  "#{mp3splt} -Q -d . -o split_@m@s@h_@M@S@H media/03.mp3 #{pairs.join(' ')} 2>&1"
puts command
system(command)
