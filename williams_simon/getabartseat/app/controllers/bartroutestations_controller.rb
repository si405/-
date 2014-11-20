class BartroutestationsController < ApplicationController

	include BartroutestationsHelper

	def index
		@bartroutestations = Bartroutestation.all
	end

	def new
		@bartroutestation = Bartroutestation.new
		@bartstations = Bartstation.all
		@bartstation_names = {}
		@bartstations.each do |bartstation|
			@bartstation_names[bartstation.station_name] = bartstation.id
		end 
		@bartroutes = Bartroute.all
		@bartroute_names = {}
		@bartroutes.each do |bartroute|
			@bartroute_names[bartroute.bart_route_name] = bartroute.id
		end 
	end

	# Create a new route station association
	def create
		binding.pry
		@bartroutestation = Bartroutestation.new(bartroutestation_params)
		if @bartroutestation.save
			flash[:success] = "Route station created"
			redirect_to bartroutes_path 
		else
			flash[:error] = "Unable to save route station. Please try again"
			render :create
		end
	end

	private
    def bartroutestation_params
      params.require(:bartroutestation).permit(:bartroute_id, :bartstation_id,:route_station_sequence)
    end

end
