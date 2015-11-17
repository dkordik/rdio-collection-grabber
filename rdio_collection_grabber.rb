#!/usr/bin/env ruby

# RDIO COLLECTION ADDITIONS GRABBER
# Find the latest additions to your Rdio collection,
# see if they're on your hard drive in a very simplistic and limited way (KISS, for now),
# and use the whatcdsearch script to download the goodies. (pass its path to this script)
# So I can automagically keep my iTunes library up-to-date with my new Rdio finds.
# Now you can stop feeling like you're neglecting your REAL library!

require 'rubygems'

#make sure we look in the execution directory first for our requires (rdio and config)
#that way we can call this script from anywhere, like cron, without issues
$: << File.dirname(__FILE__)

require 'rdioid'

begin
require 'config'
rescue Exception=>e
	puts "Error: Make sure you change config.rb.example to a real config.rb"
	exit
end

if NAME.length == 0 or KEY.length == 0 or SECRET.length == 0 or MUSIC_FOLDER.length == 0
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

Rdioid.configure do |config|
  config.client_id = KEY
  config.client_secret = SECRET
  config.redirect_uri = 'http://example.com/'
end

puts Rdioid::Client.authorization_url(:response_type => 'token')
puts "Open this URL in your browser^, click Allow, then paste the URL it directs you to, here:"

access_token = STDIN.gets.strip.split("#")[1].split("&")[0].split("=")[1]

puts "Parsed token: #{access_token}"

rdioid_client = Rdioid::Client.new

latest_album_data = rdioid_client.api_request(access_token, :method => 'getAlbumsInCollection', :count => 100, :sort => "dateAdded")

latest_albums = latest_album_data.result.map { |album| { "artist" => album.artist, "name" => album.name } }

def strip_album_name_extras!(str)
	non_album_title_text = ['- ep', 'ep', '(deluxe edition)']
	str.downcase!
	non_album_title_text.each {|s| str.gsub!(s, '') }
	str.strip!
	str
end

#get the most recent albums added to our collection
latest_albums.each do |album|

	artist_folder = "#{MUSIC_FOLDER}/#{album.artist}"
	have_artist = File.directory? artist_folder

	strip_album_name_extras!(album.name)

	if have_artist
		#check the filesystem to see if we have the album
		album_folders = Dir.entries("#{MUSIC_FOLDER}/#{album.artist}")[2..-1] #we assume you have itunes-style folders
		stripped_album_name = album.name.gsub("/","_")
		have_album = album_folders.map do |s|
			strip_album_name_extras!(s)
		end.index do |s|
			s.include? stripped_album_name
		end != nil
	end

	is_va = album.artist == "Various Artists"

	#if we don't have it and it's not some unpredictable VA album, try to download it
	if !have_artist or (!have_album and !is_va)
		command = "#{whatcdsearch_location} -a \"#{album.artist}\" -l \"#{album.name}\""
		puts "#{Time.now.strftime("%m/%d/%Y %H:%M")} **** #{command}"
		`#{command}`
	end
end
