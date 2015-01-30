# Test program to process hash

origin_trains = {"EMBR"=>{"DALY"=>["1", "5", "9"], "MLBR"=>["7", "20", "35"], "SFIA"=>["14", "27", "42"]},
 "MONT"=>{"DALY"=>["3", "6", "10"], "MLBR"=>["8", "21", "36"], "SFIA"=>["15", "29", "44"]},
 "POWL"=>{"DALY"=>["5", "7", "12"], "MLBR"=>["10", "23", "38"], "SFIA"=>["17", "30"]},
 "CIVC"=>{"DALY"=>["6", "9", "14"], "MLBR"=>["11", "24", "39"], "SFIA"=>["2", "18", "32"]},
 "16TH"=>{"DALY"=>["1", "8", "11"], "MLBR"=>["13", "26", "41"], "SFIA"=>["4", "21", "34"]},
 "GLEN"=>{"DALY"=>["2", "6", "14"], "MLBR"=>["4", "18", "31"], "SFIA"=>["9", "26", "39"]}}

destination_trains = {"EMBR"=>{"Pittsburg/Bay Point"=>["2", "18", "31"]},
 "MONT"=>{"Pittsburg/Bay Point"=>["16", "30"]},
 "POWL"=>{"Pittsburg/Bay Point"=>["14", "28", "43"]},
 "CIVC"=>{"Pittsburg/Bay Point"=>["13", "27", "42"]},
 "16TH"=>{"Pittsburg/Bay Point"=>["11", "25", "40"]},
 "GLEN"=>{"Pittsburg/Bay Point"=>["6", "20", "35"]}}


origin_station = "EMBR"

possible_trains = []
train_options = {}

binding.pry

# Process all departures from the origin station
destination_trains.each do |station, departures|
	if station == origin_station
		# Write all these departure options to the hash
#		possible_trains[origin_station] = [station,departures]
	else
		# This is an upstream station		
		departures.each do |destination, departure_times|
			departure_times.each do |departure_time|
				i = 0
				origin_trains[station].each do |train_destination,train_times|
					train_times.each do |train_time|
						if train_time.to_i <= departure_time.to_i
							# This train arrives before the departing destination train
							possible_trains[i] = 
								[train_destination, train_time, destination,departure_time]
							i = i + 1
						end
					end
				end
				if possible_trains != nul
					train_options[station] = possible_trains
				end
			end
		end
	end
end

puts possible_trains

binding.pry