class ChangeDurationToInteger < ActiveRecord::Migration
  def change
   		change_column :songs, :duration, :integer
  end
end
