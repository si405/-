module BartroutestationsHelper

# Remove all the station information from the database. Used in testing only
	def remove_all_bart_route_stations
		@stations = Bartroutestation.all
		@stations.each do |station|
			station.destroy
		end
	end

end
