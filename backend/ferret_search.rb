require './model'
require 'json'

module FerretSearch
  MAX_NUM_EXCERPTS_TO_RETURN = 10

  def self.search_for(query_string, offset)
    analyzer = MyAnalyzer.new(true)
    if query_string.split(' ').size > 1
      ferret_query = Ferret::Search::PhraseQuery.new(:lyrics)
      token_stream = analyzer.token_stream(:lyrics, query_string)
      while token = token_stream.next
        ferret_query << token.text
      end
    else
      term = analyzer.token_stream(:lyrics, query_string).next.text
      ferret_query = Ferret::Search::TermQuery.new(:lyrics, term)
    end

    num_excerpts_returned = 0

    do_query(ferret_query, offset)
  end

  def self.do_query(ferret_query, offset)
    options = {
      :sort => [
        Ferret::Search::SortField.new(:has_start_times,
          { :type => :integer, :reverse => true }),
        Ferret::Search::SortField::SCORE
      ],
      :limit => :all,
    }

    all_excerpts = []
    searcher = Ferret::Search::Searcher.new(FERRET_INDEX_DIR)
    searcher.search_each(ferret_query, options) do |doc_id, score|
      doc = searcher[doc_id]
      metadata        = JSON.load(doc[:metadata] || '{}')
      lyrics          = doc[:lyrics]
      has_start_times = (doc[:has_start_times] == '1')

      lyrics = searcher.highlight(
        ferret_query, doc_id, :lyrics, :excerpt_length => :all,
        :pre_tag => '{', :post_tag => '}').join.force_encoding('UTF-8')

      start_times = metadata['start_times'] || []
      end_times   = metadata['end_times'] || []
      lyrics.split("\n").each_with_index do |line, line_num|
        if line.include?('{')
          start_time = start_times[line_num]
          end_time = start_times[line_num + 1]
          excerpt = {
            :has_start_times  => has_start_times,
            :youtube_video_id => metadata['youtube_video_id'],
            :artist_name      => metadata['artist_name'],
            :song_name        => metadata['song_name'],
            :song_id          => metadata['song_id'],
            :line             => line,
            :line_num         => line_num,
            :start_time       => start_time,
            :end_time         => end_time,
          }
          all_excerpts << excerpt
          break if all_excerpts.size >= offset + MAX_NUM_EXCERPTS_TO_RETURN
        end
      end # next lyric line

      break if all_excerpts.size >= offset + MAX_NUM_EXCERPTS_TO_RETURN
    end # next doc

    all_excerpts.each_with_index do |excerpt, original_order|
      excerpt[:original_order] = original_order
    end

    all_excerpts = all_excerpts.sort_by do |excerpt|
      has_start_and_end_time = excerpt[:start_time] && excerpt[:end_time]
      [has_start_and_end_time ? -1 : 0, excerpt[:original_order]]
    end

    all_excerpts[offset..-1]
  end
end
