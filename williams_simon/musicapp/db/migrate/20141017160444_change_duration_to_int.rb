class ChangeDurationToInt < ActiveRecord::Migration
  def change
  	def up
   		change_column :songs, :duration, :integer
  	end

  	def down
  	 change_column :songs, :duration, :time
  	end
  end
end
