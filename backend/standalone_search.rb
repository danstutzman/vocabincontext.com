require './model'
require 'json'
require 'benchmark'
require './ferret_search'

query_string = ARGV[0] or raise "First argument: query params"
offset = ARGV[1].to_i or raise "Second argument: offset"

def excerpt_to_s(excerpt)
  [
    excerpt[:has_start_times],
    excerpt[:artist_name],
    '-',
    excerpt[:song_name],
    excerpt[:line],
    excerpt[:start_time],
    excerpt[:end_time],
  ].join(' ')
end

excerpts = nil
seconds = Benchmark.realtime {
  excerpts = FerretSearch.search_for(query_string, offset)
}
puts "#{seconds} seconds"

labeled_excerpts, unlabeled_excerpts = excerpts.partition { |excerpt|
  excerpt[:start_time] && excerpt[:end_time]
}

puts '__Labeled'
labeled_excerpts.each_with_index do |excerpt, i|
  puts "#{i} #{excerpt_to_s(excerpt)}"
end

puts '__Unlabeled'
unlabeled_excerpts.each_with_index do |excerpt, i|
  puts "#{i} #{excerpt_to_s(excerpt)}"
end
