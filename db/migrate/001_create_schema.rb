class CreateSchema < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.integer :song_id,     :null => false
      t.integer :artist_id,   :null => false
      t.string  :artist_name, :null => false
      t.string  :song_name,   :null => false
      t.text    :lyrics,      :null => false
      t.string  :youtube_video_id
      t.timestamps
    end
    add_index :songs, :song_id, :unique => true
    add_index :songs, :artist_id

    create_table :alignments do |t|
      t.integer :song_id,       :null => false
      t.integer :line_num,      :null => false
      t.integer :start_centis,  :null => false
      t.integer :finish_centis, :null => false
      t.string :location,       :length => 2
    end
    add_index :alignments, :song_id
    add_index :alignments, [:song_id, :line_num], :unique => true

    create_table :tasks do |t|
      t.string :action, :null => false
      t.integer :song_id, :null => false
      t.integer :alignment_id
      t.string :command_line
      t.timestamp :started_at 
      t.timestamp :completed_at 
      t.text :stdout
      t.text :stderr
      t.integer :exit_status
    end
    add_index :tasks, :song_id
  end
end
