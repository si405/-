class Label < ActiveRecord::Base
	has_many :artists
	validates :label_name, uniqueness: true
end
