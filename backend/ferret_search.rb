require File.join(File.dirname(__FILE__), './model')
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
        Ferret::Search::SortField.new(:has_alignments,
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
      has_alignments  = (doc[:has_alignments].to_i == 1)
      lyrics          = doc[:lyrics]
      song_id         = doc[:song_id]

      lyrics = searcher.highlight(
        ferret_query, doc_id, :lyrics, :excerpt_length => :all,
        :pre_tag => '{', :post_tag => '}').join.force_encoding('UTF-8')

      alignments_by_line_num = [nil] * lyrics.split("\n").size
      if has_alignments
        # avoid performance hit of querying the db if not needed
        Alignment.all(:song_id => song_id).each do |alignment|
          alignments_by_line_num[alignment.line_num] = alignment
        end
      end

      lyrics.split("\n").each_with_index do |line, line_num|
        if line.include?('{')
          alignment = alignments_by_line_num[line_num]
          excerpt = {
            :youtube_video_id => metadata['youtube_video_id'],
            :artist_name      => metadata['artist_name'],
            :song_name        => metadata['song_name'],
            :song_id          => song_id,
            :line             => line,
            :line_num         => line_num,
            :alignment        => alignment,
          }
          all_excerpts << excerpt
          break if all_excerpts.size >= offset + MAX_NUM_EXCERPTS_TO_RETURN
        end
      end # next lyric line

      break if all_excerpts.size >= offset + MAX_NUM_EXCERPTS_TO_RETURN
    end # next doc
    searcher.close

    all_excerpts.each_with_index do |excerpt, original_order|
      excerpt[:original_order] = original_order
    end

    all_excerpts = all_excerpts.sort_by do |excerpt|
      [excerpt[:alignment] ? -1 : 0, excerpt[:original_order]]
    end

    all_excerpts[offset..-1]
  end

  def self.find_song_by_id(song_id)
    ferret_query = Ferret::Search::TermQuery.new(:song_id, song_id)
    searcher = Ferret::Search::Searcher.new(FERRET_INDEX_DIR)
    doc = nil
    searcher.search_each(ferret_query) do |doc_id, score|
      doc = searcher[doc_id]
      break
    end
    searcher.close
    doc
  end

  def self.update_index_from_db(song_id)
    with_ferret_index do |index|
      song = Song.first(:id => song_id)
      metadata = {}
      metadata['song_name'] = song.song_name
      metadata['artist_name'] = song.artist_name
      if song.youtube_video_id
        metadata['youtube_video_id'] = song.youtube_video_id
      end
      to_update = {
        :lyrics         => song.lyrics,
        :has_alignments => (song.alignments.size > 0) ? 1 : 0,
        :metadata       => JSON.dump(metadata),
      }
      index.query_update "song_id:#{song.id}", to_update
    end
  end
end
