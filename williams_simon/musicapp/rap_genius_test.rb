require 'rapgenius'
require 'pry'

def search_for_songs(song)
	songs = RapGenius.search_by_song(song_name) 
	possible_songs = {}
	songs.each do |song|
		possible_songs[song.artist.name] = song.name
	end
	return possible_songs
end


def get_songs_for_artist(artist)
	song = RapGenius::Song.find(song_id)
	songs = search.map(&:id)
	songs.each do |song|
		song.RapGenius::Song.find(song_id)
	end
end 

search_by_artist("The Jam")

