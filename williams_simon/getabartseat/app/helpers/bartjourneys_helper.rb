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

	# Determine the schedule between the selected origin and 
	# destination stations. This is the main function.

	def calculate_bart_times(journeydetails)

		# Determine the start and end stations
		# Pluck returns an array so only the first element is populated and needed

		start_station_code = Bartstation.where("id = #{journeydetails.start_station_id}").pluck("short_name")[0]
		@start_station = Bartstation.where("id = #{journeydetails.start_station_id}").pluck("station_name")[0]
		end_station_code = Bartstation.where("id = #{journeydetails.end_station_id}").pluck("short_name")[0]
		@end_station = Bartstation.where("id = #{journeydetails.end_station_id}").pluck("station_name")[0]

		bartjourney_options = get_bart_schedule(start_station_code,end_station_code,@bartjourney.direction)

		# Return the results

		return bartjourney_options

	end

	# Get the schedule information between the origin and destination from the 
	# BART API. The origin and destination are passed in as arrays

	def get_bart_schedule(origin_station, destination_station, direction)

		response = Typhoeus.get("http://api.bart.gov/api/sched.aspx?cmd=depart&orig=#{origin_station}&dest=#{destination_station}&date=now&key=ZZLI-UU93-IMPQ-DT35")

		# Extract the station names and short names

		response_XML = Nokogiri.XML(response.body)

		# Create a hash list of the station names and abbreviations

		# Use a hash to store the route options to manage duplicate entries

		bartroute_options = {}
		route_departure_times ={}

		response_XML.xpath("///trip").each do |node|
			
			# Check to see if any transfers are involved
			# *** IF SO DEAL WITH THOSE LATER ****


			if node['transfercode'] == nil

				# There is only one leg for this journey
				node.children.each do |leg|

					# Get the available bart routes from the "leg" of the journey

					bartroute_options[node.at('leg')['trainHeadStation']] = 
						node.at('leg')['trainHeadStation']
				
				end

			end

			# If the direction is "normal", loop through the route options and find the 
			# real time departures for each route option that originates from the origin 
			# station.
			# If the direction is "reverse", find the upstream stations and include the 
			# departures from those stations

			departure_times = {}
			departure_stations = []			

			if @bartjourney.direction == "Normal"
				bart_direction = nil
				departure_times = get_real_time_departures(origin_station,bart_direction)
				route_departure_times = 
					filter_departures(departure_times,bartroute_options)
			else
				
				# *** For now assume that reverse = southbound for testing upstream at ***
				# *** SF stations ***
				
				bart_direction = 's'
				
				# Find the departure times from the current station heading in the 
				# reverse direction
				
				origin_departure_times = get_real_time_departures(origin_station,bart_direction)
				
				# For the reverse direction find the upstream stations on each route
				# serving the origin station. The returned hash has each upstream 
				# bartroutestation
				
				departure_stations = get_upstream_stations(origin_station)
				
				# For each route and upstream station found
				#     Find the departure times from each of those stations
				# 	  Due to the BART API it's necessary to retrieve all departures
				#     in the selected direction and then filter the results

				upstream_departure_times = {}
				departure_stations.each do |bartroute, upstream_stations|
					upstream_stations.each do |departure_station|
						
						# The array contains the id of the station and the API needs the short name
						start_station_code = Bartstation.where("id = #{departure_station.bartstation_id}").pluck("short_name")[0]
						
						# Get the departure times for the upstream station in the selected
						# direction

						upstream_departure_times[start_station_code] = 
							get_real_time_departures(start_station_code,bart_direction)
						
					end
				end

				# For each train departing the origin station find the corresponding 
				# arrival/departure time at the upstream stations, e.g. if the SFO train 
				# leaves EMBR at 17:00 find out what time it arrives/departs MONT, POWL etc.

				departure_train_options = {}
				origin_departure_times.each do |train_route,train_times|
					times_from_each_station = {}
					i = 0
					latest_time = -1
					train_times.each do |train_time|
						times_from_each_station[origin_station] = train_times[i]
						upstream_departure_times.each do |upstream_station,upstream_times|
							if upstream_times[train_route][i].to_i > latest_time
								times_from_each_station[upstream_station] = upstream_times[train_route][i]
								latest_time = upstream_times[train_route][i].to_i

								binding.pry
							end
						end
					end
					i = i + 1
					departure_train_options[train_route] = times_from_each_station
				end

				route_departure_times = departure_train_options
			end
		end

		return route_departure_times
	end

	# Use the departure station to get the real-time departures from that station
	# There will be trains to other destinations and these will be filtered later
	# as there is no way to request real-time data from the origin station to the 
	# destination station

	def get_real_time_departures(origin_station,direction)

		# Set up the hash to store the departure options for this destination

		if direction == nil
			direction_string = nil
		else
			direction_string = "dir=#{direction}&"
		end

		response = Typhoeus.get("http://api.bart.gov/api/etd.aspx?cmd=etd&orig=#{origin_station}&#{direction_string}key=ZZLI-UU93-IMPQ-DT35")

		# Extract the station names and short names

		response_XML = Nokogiri.XML(response.body)

		# Create a hash list of the station names and abbreviations
		# node provides the full name of the station and next node is 
		# the abbreviation


		departure_options = {}

		i = 0

		response_XML.xpath("///etd").each do |node|

			# Process the children of each destination node to get the times

			departure_times = []
			current_station = node.css('abbreviation').text
			
			j = 0

			node.css('minutes').each do |departure|
				
				# Ignore any trains that are already leaving
				if departure.text != "Leaving"
					departure_times[j] = departure.text
					j = j + 1
				end

			end

			departure_options[current_station] = departure_times

			i = i + 1

		end

		return departure_options

	end

	# This function gets passed a list of the real-time departures and the list of possible 
	# routes between the origin and destination. It filters out the real-time departures for 
	# the possible routes.

	def filter_departures(departure_times,bartroute_options)
		# Filter the results of the real-time departures to find those that match the 
		# route options. 

		filtered_departure_times = {}

		departure_times.each do |station,times|
			bartroute_options.each do |bartroute_station,v|
				if station == bartroute_station
					station_name = Bartstation.where("short_name = '#{bartroute_station}'").pluck("station_name")[0]
					filtered_departure_times[station_name] = times
				end
			end
		end

		return filtered_departure_times
	end

	# Find the upstream stations from the origin station 
	def get_upstream_stations(origin_station)
		
		starting_station = Bartstation.where("short_name = '#{origin_station}'").pluck("id")[0]
		
		# Find all the instances of the starting station
		# The station may appear on multiple routes
		
		station_routes = {}
		
		Bartroutestation.where("bartstation_id = #{starting_station}").each do |routestation|
				station_routes[routestation.bartroute_id] = routestation.route_station_sequence
		end

		# For each route that has the starting station:
		#      Find the starting station 
		#      Find the next 5 stations in the reverse direction
		#      (The stations are sequenced in the database to increment from the east 
		#      bay direction)

		upstream_stations = {}
		station_routes.each do |station_route,station_sequence|
			bartroute_id = station_route
			bartstation_sequence = station_sequence			
			upstream_stations[bartroute_id] = 
				Bartroutestation.where("bartroute_id = #{bartroute_id} AND route_station_sequence > #{bartstation_sequence}").take(5)
		end

		# Return the list of upstream stations for each route from the origin station

		return upstream_stations

	end


end