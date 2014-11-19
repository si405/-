class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
	  t.string :post_title
      t.string :post_url
      t.references :user, index: true
      t.timestamps
    end
  end
end
