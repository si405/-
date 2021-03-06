class Artist < ActiveRecord::Base
	has_many :songs, :dependent => :delete_all
	belongs_to :label
	validates :artist_name, uniqueness: true
end
