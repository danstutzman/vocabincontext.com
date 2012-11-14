# see https://github.com/jkraemer/ferret/blob/master/ruby/TUTORIAL
require 'ferret'

index_path = File.expand_path('../index', __FILE__)
index_already_existed = File.exists?(index_path)
index = Ferret::Index::Index.new({
  :default_input_field => nil,
  :id_field => :song_id,
  :path => index_path,
})

if !index_already_existed
  index.field_infos.add_field :song_id, {
    :store => :yes, :index => :no, :term_vector => :no
  }
  index.field_infos.add_field :title, {
    :store => :yes, :index => :no, :term_vector => :no
  }
  index.field_infos.add_field :content, {
    :store => :no, :index => :yes, :term_vector => :no
  }
end

if !index_already_existed
  index << {
    :song_id => 1,
    :title => 'the title one',
    :content => 'contents one',
  }
  index << {
    :song_id => 2,
    :title => 'the title two',
    :content => 'contents two',
  }
end

index.search_each('content:contents') do |id, score|
  doc = index[id]
  puts "#{doc[:song_id]} (\"#{doc[:title]}\")"
end
