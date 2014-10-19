class CreateLabels < ActiveRecord::Migration
  def change
    create_table :labels do |t|
      t.string :label_name
      t.timestamps
    end
  end
end
