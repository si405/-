class CreateArtists < ActiveRecord::Migration
  def change
    create_table :artists do |t|
    	t.string :artist_name
    	t.integer :artist_age
      t.timestamps
    end
  end
end
