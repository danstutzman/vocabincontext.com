require './model'
require 'json'
require 'benchmark'
require './ferret_search'

load File.join(File.dirname(__FILE__), 'connect_to_db.rb')

query_string = ARGV[0] or raise "First argument: query params"

if ARGV[1]
  offset = ARGV[1].to_i
else
  raise "Second argument: offset"
end

if ARGV[2]
  exact_match = (ARGV[2] == 'true')
else
  raise "Third argument: exact_match (true or false)"
end

def excerpt_to_s(excerpt)
  [
    excerpt[:has_alignments],
    excerpt[:artist_name],
    '-',
    excerpt[:song_name],
    excerpt[:line],
    excerpt[:alignment] && excerpt[:alignment].start_centis,
    excerpt[:alignment] && excerpt[:alignment].finish_centis,
  ].join(' ')
end

excerpts = nil
seconds = Benchmark.realtime {
  excerpts = FerretSearch.search_for(query_string, exact_match, offset)
}
puts "#{seconds} seconds"

aligned_excerpts, unaligned_excerpts =
  excerpts.partition { |excerpt| excerpt[:alignment] }

puts '__Aligned'
aligned_excerpts.each_with_index do |excerpt, i|
  puts "#{i} #{excerpt_to_s(excerpt)}"
end

puts '__Unaligned'
unaligned_excerpts.each_with_index do |excerpt, i|
  puts "#{i} #{excerpt_to_s(excerpt)}"
end
