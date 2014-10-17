class SongsController < ApplicationController

	def all
		@songs = Song.all.order(:song_name)
	end

	def index
	   @artist = Artist.find(params[:artist_id])
	end

	def new
		@artist = Artist.find(params[:artist_id])
	end

	def create
		@artist = Artist.find(params[:artist_id])
		@song = @artist.songs.create(song_params)
   		redirect_to artist_songs_path(@artist)
	end

	def edit
		@artist = Artist.find(params[:artist_id])
		@song = Song.find(params[:id])
	end

	def update
		@song = Song.find(params[:id])
		@song.update(song_params)
		redirect_to artist_songs_path
	end


	private
	    def song_params
  	    params.require(:song).permit(:song_name, :genre, :duration, :release_date)
  		end
end