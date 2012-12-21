require File.join(File.dirname(__FILE__), './model')
require 'json'

module FerretSearch
  MAX_NUM_EXCERPTS_TO_RETURN = 10

  def self.search_for(query_string, exact_match, offset)
    analyzer = MyAnalyzer.new(!exact_match)
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

    do_query(ferret_query, exact_match, offset)
  end

  def self.do_query(ferret_query, exact_match, offset)
    options = {
      :sort => [
        Ferret::Search::SortField.new(:has_alignments,
          { :type => :integer, :reverse => true }),
        Ferret::Search::SortField::SCORE
      ],
      :limit => :all,
    }

    all_excerpts = []
    index_path = FERRET_INDEXES_DIR +
      (exact_match ? '/es_exact' : '/es_stemmed')
    searcher = Ferret::Search::Searcher.new(index_path)
    searcher.search_each(ferret_query, options) do |doc_id, score|
      doc = searcher[doc_id]
      metadata        = JSON.load(doc[:metadata] || '{}')
      has_alignments  = (doc[:has_alignments].to_i == 1)
      lyrics          = doc[:lyrics]
      scraped_song_id = doc[:scraped_song_id]

      lyrics = searcher.highlight(
        ferret_query, doc_id, :lyrics, :excerpt_length => :all,
        :pre_tag => '{', :post_tag => '}').join.force_encoding('UTF-8')

      alignments_by_line_num = [nil] * lyrics.split("\n").size
      if has_alignments # avoid performance hit of querying the db if not needed
        if song = Song.find_by_scraped_song_id(scraped_song_id)
          Alignment.where(:song_id => song.id).each do |alignment|
            alignments_by_line_num[alignment.line_num] = alignment
          end
        end
      end

      lyrics.split("\n").each_with_index do |line, line_num|
        if line.include?('{')
          alignment = alignments_by_line_num[line_num]
          excerpt = {
            :youtube_video_id => metadata['youtube_video_id'],
            :artist_name      => metadata['artist_name'],
            :song_name        => metadata['song_name'],
            :scraped_song_id  => scraped_song_id,
            :line             => line,
            :line_num         => line_num,
            :alignment        => alignment,
            :has_alignments   => has_alignments,
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

  def self.find_song_by_scraped_song_id(scraped_song_id)
    ferret_query = Ferret::Search::TermQuery.new(
      :scraped_song_id, scraped_song_id)
    searcher = Ferret::Search::Searcher.new("#{FERRET_INDEXES_DIR}/es_exact")
    doc = nil
    searcher.search_each(ferret_query) do |doc_id, score|
      doc = searcher[doc_id]
      break
    end
    searcher.close
    doc
  end

  def self.update_indexes_from_db(song)
    [false, true].each do |exact_match|
      with_ferret_index(exact_match) do |index|
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
        index.query_update "scraped_song_id:#{song.scraped_song_id}", to_update
      end
    end
  end
end
