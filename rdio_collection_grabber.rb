#!/usr/bin/env ruby

# RDIO COLLECTION ADDITIONS GRABBER
# Find the latest additions to your Rdio collection,
# see if they're on your hard drive in a very simplistic and limited way (KISS, for now),
# and use the whatcdsearch script to download the goodies. (pass its path to this script)
# So I can automagically keep my iTunes library up-to-date with my new Rdio finds.
# Now you can stop feeling like you're neglecting your REAL library!

require 'rubygems'
require 'rdio'

begin
require 'config'
rescue Exception=>e
	puts "Error: Make sure you change config.rb.example to a real config.rb"
	exit
end

if KEY.length == 0 or SECRET.length == 0 or NAME.length == 0 or MUSIC_FOLDER.length == 0
	puts "Error: Make sure you've filled out your config.rb"
end

whatcdsearch_location = ARGV[0]

if ARGV.length != 1
	puts "USAGE: #{$0} \"PATH_TO_WHATCDSEARCH\""
	exit
end

class Hash #too addicted to JS-esque object notation. sorry rb-kids
  def method_missing(n)
    self[n.to_s]
  end
end

rdio = Rdio.new([KEY,SECRET])

user = rdio.call("findUser", {"vanityName" => NAME})

user_key = user.result.key

latest_album_data = rdio.call("getAlbumsInCollection", {"user" => user_key, "count" => 20, "sort" => "dateAdded"})

latest_albums = latest_album_data.result.map { |album| { "artist" => album.artist, "name" => album.name } }

#get the most recent albums added to our collection
latest_albums.each do |album|
	artist_folder = "#{MUSIC_FOLDER}/#{album.artist}"
	have_artist = File.directory? artist_folder

	if have_artist
		#check the filesystem to see if we have the album
		album_folders = Dir.entries("#{MUSIC_FOLDER}/#{album.artist}")[2..-1] #we assume you have itunes-style folders
		have_album = album_folders.map(&:downcase).include? album.name.downcase
	end

	is_va = album.artist == "Various Artists"

	#if we don't have it and it's not some unpredictable VA album, try to download it
	if !have_artist or (!have_album and !is_va)
		puts "**** ATTEMPTING DOWNLOAD OF \"#{album.artist}\" \"#{album.name}\""
		command = "#{whatcdsearch_location} -a \"#{album.artist}\" -l \"#{album.name}\""
		puts "**** #{command}"
		`#{command}`
	end
end
