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

	def calulate_bart_times(journeydetails)

		# Determine the start and end stations
		# Pluck returns an array so only the first element is populated and needed

		start_station_code = Bartstation.where("id = #{journeydetails.start_station_id}").pluck("short_name")[0]
		@start_station = Bartstation.where("id = #{journeydetails.start_station_id}").pluck("station_name")[0]
		end_station_code = Bartstation.where("id = #{journeydetails.end_station_id}").pluck("short_name")[0]
		@end_station = Bartstation.where("id = #{journeydetails.end_station_id}").pluck("station_name")[0]

		bartjourney_options = get_bart_schedule(start_station_code,end_station_code,@bartjourney.direction)

		# Return the results for display

		binding.pry

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
			

			if @bartjourney.direction = "Normal"
				departure_times = get_real_time_departures(origin_station)
				route_departure_times = 
					filter_departures(departure_times,bartroute_options)
			end
		end

		return route_departure_times
	end

	# Use the departure station to get the real-time departures from that station
	# There will be trains to other destinations and these will be filtered later
	# as there is no way to request real-time data from the origin station to the 
	# destination station

	def get_real_time_departures(origin_station)

		# Set up the hash to store the departure options for this destination

		response = Typhoeus.get("http://api.bart.gov/api/etd.aspx?cmd=etd&orig=#{origin_station}&key=ZZLI-UU93-IMPQ-DT35")

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
					puts j, current_station, departure.text, departure_times
					j = j + 1
				end

			end

			departure_options[current_station] = departure_times

			i =+ 1

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


end