require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra/base'
require 'haml'
require './model'

QUERY_REGEX = /^\w+$/

class BackendApp < Sinatra::Base
  configure do
    set :haml, {:format => :html5, :escape_html => true}
  end

  def get_term_counts
    reader = Ferret::Index::IndexReader.new('index')
    @term_counts = []
    reader.terms(:lyrics).each do |term, doc_freq|
      if doc_freq > 100
        @term_counts << [term, doc_freq]
      end
    end
    @term_counts = @term_counts.sort_by { |term_count| -term_count[1] }
    @term_counts = @term_counts[0..100]
  end

  def serve_search
    query = params['query']
    raise "Query doesn't pass white list" if query && !query.match(QUERY_REGEX)

    if query
      @results = []
      with_ferret_index do |index|
        index.search_each("lyrics:#{query}") do |doc_id, score|
          doc = index[doc_id]
          song_id = doc[:song_id]

          term_vector = index.term_vector(doc_id, :lyrics)
          term = term_vector.terms.find { |term| term.text == query }
          ranges = term.positions.map { |position|
            term_vector.offsets[position].start...\
            term_vector.offsets[position].end
          }

          line_start = 0
          lines = doc[:lyrics].split("\n")
          next_range = ranges.shift
          next_line = lines.shift
          line_start = 0
          line_end = next_line.size
          #@results << "#{line_start}-#{line_end} #{next_line}"
          adjustments_for_this_line = 0
          while next_line != nil
            if next_range &&
               next_range.begin >= line_start &&
               next_range.begin < line_end

              pos = next_range.begin - line_start + adjustments_for_this_line
              next_line[pos...pos] = '*'
              adjustments_for_this_line += 1

              pos2 = next_range.end - line_start + adjustments_for_this_line
              next_line[pos2...pos2] = '*'
              adjustments_for_this_line += 1

              @results << "#{song_id}: #{next_line}"

              next_range = ranges.shift
            else
              next_line = lines.shift
              adjustments_for_this_line = 0
              break if next_line.nil?
              line_start = line_end + 1
              line_end = line_start + next_line.size
              #@results << "#{line_start}-#{line_end} #{next_line}"
            end
          end
        end
      end
    end

    get_term_counts
    haml :search
  end

  get '/' do
    redirect '/search'
  end

  get '/search' do
    serve_search
  end

  post '/search' do
    serve_search
  end
end
