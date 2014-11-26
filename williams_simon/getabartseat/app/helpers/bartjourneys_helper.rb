module BartjourneysHelper

	# Get all the station names from the database

	def get_station_names_DB
		@allbartstations = Bartstation.all
		@bartstations = {}
		@allbartstations.each do |bartstation|
			@bartstations[bartstation.station_name] = 
					bartstation.id
		end
	
		return @bartstations
	end


end
