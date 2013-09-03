# encoding: utf-8

require "rubygems"
require "taglib"
require 'optparse'


Encoding.default_internal = 'UTF-8'
Encoding.default_external = 'UTF-8'

#where the args will go
ARGS = {}
#particles not to be capitalized
PARTICLES = ["con"]

OptionParser.new do |opts|
	opts.banner = "Usage: #{$0} -f <folder>"
	
	opts.on("-f", "--folder FOLDER", "Select folder with -f option") do |folder|
		ARGS[:folder] = folder.encode('utf-8', 'iso-8859-1')
	end
	
	ARGS[:verbose] = false
	opts.on("-v", "--verbose", "Run verbosely") do |v|
		ARGS[:verbose] = v
	end
	
	opts.on("--list", "List artist tag in the folders files") do |list|
		ARGS[:list] = list
	end
	
	opts.on("--camelize", "Changed the names to be conformant with camel-case") do |camelize|
		ARGS[:camelize] = camelize
	end
	
	opts.on("--tclean x,y,z", Array, "Clean the titles by removing the PART string from them") do |list|
		ARGS[:tclean] = list.map {|x| x.encode('utf-8', 'iso-8859-1') }
	end
	
end.parse!

#abort "Number of parameters is must be one: the directory" if ARGV.length > 1

def cd(dir)
	Dir.chdir(dir)
	puts "Current directory is  #{dir}/"
end

class AudioFile
	
	attr_reader :file_name
	
	def initialize(file_name)  
		#variable doesn't exist before this
		@file_name = file_name
	end 
	
	def artist
		if not @artist.nil?
			return @artist
		end
		
		TagLib::FileRef.open(file_name) do |audio_file|
			#no FileRef or no tag
			if audio_file.nil? || audio_file.tag.nil?
				return nil
			end	
			
			#if some tag doesn't exist: nil it, else add what's in the file
			if audio_file.tag.artist.nil?
				return nil
			else
				@artist=audio_file.tag.artist
			end
		end
	end
	
	def title
		if not @title.nil?
			return @title
		end
		
		TagLib::FileRef.open(file_name) do |audio_file|
			#no FileRef or no tag
			if audio_file.nil? || audio_file.tag.nil?
				return nil
			end	
			
			#if some tag doesn't exist: nil it, else add what's in the file
			if audio_file.tag.artist.nil?
				return nil
			else
				@title=audio_file.tag.title
			end
		end
	end

	
	#sizes for year, artist and title
	def pretty_print(size1, size2, size3)
		puts "#{year.to_s.ljust(size1)} #{artist.to_s.ljust(size2)} #{title.to_s.ljust(size3)}  #{file_name}"
	end
end


class Mp3File < AudioFile
	
	def year
		if not @year.nil?
			return @year
		end		
		
		TagLib::MPEG::File.open(file_name) do |mp3_file| 
			
			tag = mp3_file.id3v2_tag
			if tag.nil?
				puts "\tNo tag found in this file !!!"
				return nil
			end
			
			if tag.frame_list('TDRC').empty?
				puts "\tNo year was found..."
				return nil
			end
			
			return tag.frame_list('TDRC').first.field_list.first
		end
	end
	
	def year=(year)
		TagLib::MPEG::File.open(file_name) do |mp3_file| 
			
			mp3_file.id3v2_tag.frame_list('TDRC').first.field_list = [year]
			mp3_file.save()
		end
		@year = year
	end
end

class Mp4File < AudioFile
	
	def year
		if not @year.nil?
			return @year
		end		

		TagLib::MP4::File.open(file_name) do |mp4_file|
			
			#TODO protect from nil --> has_key?
			item_list_map = mp4_file.tag.item_list_map
			return item_list_map["©day"].to_string_list.first
		end
	end
	
	def year=(year)
		TagLib::MP4::File.open(file_name) do |mp4_file|
			
			#TODO protect from nil
			item_list_map = mp4_file.tag.item_list_map
			
			#replaces previous "©day" value
			item_list_map.insert("©day", TagLib::MP4::Item.from_string_list([year]))
			mp4_file.save()
		end
		@year = year
	end
end

class AudioFactory
	def self.create(file_name)
		@file_name = file_name
		if mp3?
			return Mp3File.new(file_name)
		elsif mp4?
			return Mp4File.new(file_name)
		else
			raise "File type not supported: #{file_name}"
		end
	end
		
	def self.mp3?
		return @file_name =~ /.mp3$/
	end

	def self.mp4?
		return @file_name =~ /.m4a$/
	end
end
	




def list(files)
	#lists with all values to pretty-print
	pretty_artists = []
	pretty_titles = []
	pretty_years = []
	pretty_filenames = []
	
	#run all files and fill the pretty arrays 
	files.each do|file_name| 
		TagLib::FileRef.open(file_name) do |audio_file|
			
			pretty_filenames.push(file_name)
			
			#no FileRef or no tag
			if audio_file.nil? || audio_file.tag.nil?
				pretty_artists.push("NIL")
				pretty_titles.push("NIL")
				pretty_years.push("NIL")
				#puts "\tFile #{file_name} has no tags ..."
				next
			end	
			
			#if some tag doesn't exist: nil it, else add what's in the file
			if audio_file.tag.artist.nil?
				pretty_artists.push("NIL")
			else
				pretty_artists.push(audio_file.tag.artist)
			end
			if audio_file.tag.title.nil?
				pretty_titles.push("NIL")
			else
				pretty_titles.push(audio_file.tag.title)
			end
			if audio_file.tag.year.nil?
				pretty_years.push("NIL")
			else
				pretty_years.push(audio_file.tag.year)
			end
		
			#artist = audio_file.tag.artist  
			#title = audio_file.tag.title  
			#puts " Artist #{artist} - #{title}\tin file #{file_name}"
		end
	end
	
	##print the arrays
	
	#get sizes for pretty print
	longest_artist = pretty_artists.map{|x| x.size}.max
	longest_title = pretty_titles.map{|x| x.size}.max
	longest_year = pretty_years.map{|x| x.size}.max
	
	#assumes pretty arrays have the same length
	(0...pretty_artists.length).each do |i|
		puts "#{pretty_years[i].to_s.ljust(longest_year)}  "+
		       "#{pretty_artists[i].ljust(longest_artist)}  "+
		       "#{pretty_titles[i].ljust(longest_title)}  "+
		       "#{pretty_filenames[i]}"
	end
end

def camelize(files)
	files.each do|file_name| 
		TagLib::FileRef.open(file_name) do |audio_file|
			
			### change artist
			artist = audio_file.tag.artist  
			
			#capitalize all words in the name 
			capital_words= artist.split(" ").map {|w| w.capitalize }
			#downcase those that are particles
			ok_words= capital_words.map{|w| if PARTICLES.include? w.downcase then w.downcase else w end } 
			
			new_artist = ok_words.join(" ")
			
			### change title
			title = audio_file.tag.title
			
			#capitalize all words in the name 
			##
			## TODO > name.name and name-name
			## TODO > isto (Roberto > (Por la guerra)
			##
			capital_words= title.split(" ").map {|w| w.capitalize }
			#downcase those that are particles
			ok_words= capital_words.map{|w| if PARTICLES.include? w.downcase then w.downcase else w end } 
			
			new_title = ok_words.join(" ")
			
			
			audio_file.tag.artist = new_artist
			audio_file.tag.title = new_title
			audio_file.save()
		end
	end
end


def tclean(files, clean_str)
	files.each do|file_name| 
		TagLib::FileRef.open(file_name) do |audio_file|
			
			#remove :tclean from title tag
			new_title = audio_file.tag.title  
			new_title.slice!(clean_str)
			audio_file.tag.title = new_title
			audio_file.save()
		end
	end
end

#artists array to build the map of all possibilities
#puts artists_array.uniq.map{|s| "\"#{s.force_encoding('utf-8')}\" => "}


def list3(files)
	pretty_artists = []
	pretty_titles = []
	pretty_years = []
	pretty_filenames = []
	
	#make a list of audio files
	audio_files = files.map {|f| AudioFactory.create(f)}
	
	year_space = audio_files.map{|f| f.year}.map{|y| y.size}.max
	artist_space= audio_files.map{|f| f.artist}.map{|a| a.size}.max
	title_space = audio_files.map{|f| f.title}.map{|t| t.size}.max
	
	#assumes pretty arrays have the same length
	audio_files.each{|f| f.pretty_print(year_space, artist_space, title_space)}
end



cd(ARGS[:folder])

#search for audio files: ~mp3 and ~m4a
all_files = Dir.glob("*.*")
all_files = all_files.select{|fn| fn =~ /.m4a$/ || fn =~ /.mp3$/ }

if ARGS[:list]
	list3(all_files)
end

if ARGS[:camelize]
	camelize(all_files)
	puts ""
	list(all_files)
end

if not ARGS[:tclean].nil? && ARGS[:tclean]!=0
	longest_tclean= ARGS[:tclean].map{|x| x.size}.max
	ARGS[:tclean].each{|w| puts "Removing #{w.ljust(longest_tclean)} from titles ..." }
	#ARGS[:tclean].each{|s| tclean(all_files,s) }
	puts ""
	list(all_files)
end

