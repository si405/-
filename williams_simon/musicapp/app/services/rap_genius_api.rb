module RapGeniusApi

# Search for songs by name and then filter based on the artist
# since the RapGenius API doesn't allow for this level of 
#searching

def self.search_for_songs(song_name, artist_name)
	songs = RapGenius.search_by_title(song_name) 
	artist_song_details = {}
	songs.each do |song|
		# Check if the song title and artist match
		if ((song.title.include? song_name) and
			(song.artist.name.include? artist_name))
			artist_song_details[song.artist.name] = song.media.first.url

		end
	end
	return artist_song_details
end


def self.get_songs_for_artist(artist)
	song = RapGenius::Song.find(song_id)
	songs = search.map(&:id)
	songs.each do |song|
		song.RapGenius::Song.find(song_id)
	end
end 

end