class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.references :artist, index: true
      t.string :song_name
      t.string :genre
      t.date   :release_date
      t.integer  :duration
      t.timestamps
    end
  end
end
