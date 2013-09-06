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
	
	opts.on("-f", "--folder FOLDER", "The folder where the files modification will happen") do |folder|
		ARGS[:folder] = folder.encode('utf-8', 'iso-8859-1')
	end
	
	
	ARGS[:verbose] = false
	opts.on("-v", "--verbose", "Run verbosely") do |v|
		ARGS[:verbose] = v
	end
	
	ARGS[:verbose] = false
	opts.on("--force", "Force action if some doubts appear") do |f|
		ARGS[:force] = f
	end
	
	
	opts.on("--list", "List artist tag in the folders files") do |list|
		ARGS[:list] = list
	end
	
	opts.on("--parsedate", "Parsed dates in the formats YYYY-MM-DD and DD-MM-YYYY and fills the date tag with that info",
				"  Use the force option to overide present year tag information.") do |parsedate|
		ARGS[:parsedate] = parsedate
	end
	
	opts.on("--contextdate", "Add description.") do |contextdate|
		ARGS[:contextdate] = contextdate
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
	puts "cd #{dir.split("/")[-1]}"
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

	def genre
		if not @genre.nil?
			return @genre
		end
		
		TagLib::FileRef.open(file_name) do |audio_file|
			#no FileRef or no tag
			if audio_file.nil? || audio_file.tag.nil?
				return nil
			end	
			
			#if some tag doesn't exist: nil it, else add what's in the file
			if audio_file.tag.genre.nil?
				return nil
			else
				@genre=audio_file.tag.genre
			end
		end
	end
	
	def full_date?
		split_date = year().split("-")
		return split_date.length==3 &&
			split_date[0].length==4 &&
			split_date[1].length==2 &&
			split_date[2].length==2
	end
		
	#sizes for year, artist and title
	def pretty_print(size1, size2, size3, size4)
		return "#{year.to_s.ljust(size1)} #{artist.to_s.ljust(size2)} #{title.to_s.ljust(size3)} #{genre.to_s.ljust(size4)}  #{file_name}"
	end
	
	def get_date_from_name(*patterns)
		matches = patterns.map do |p| 
			
			file_name =~ p #match
			
			if not $~.nil?
				#found a pattern: place it in the YYYY-MM-DD form if needed
				pieces = $~.to_s.split("-")
				
				if pieces[0].length!=4
					pieces.reverse!
				end
				
				next pieces.join("-")
			else 
				next nil
			end
		end
		
		matches.compact!
		
		if matches.uniq.length>1
			raise "\tMore then one match of date in filename!!"
		end
		
		return matches[0] #if no match => nil
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
				puts "\tNo tag found in this file while calling year()!!!"
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
			
			tag = mp3_file.id3v2_tag
			if tag.nil?
				puts "\tNo tag found in this file while calling year=#{year}!!!"
				return nil
			end
			tag.frame_list('TDRC').first.field_list = [year]
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
	
	def self.bulk_create(file_name_list)
		return file_name_list.map {|f| AudioFactory.create(f)}
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
	audio_files = AudioFactory.bulk_create(files)
	
	year_space = audio_files.map{|f| f.year}.map{|y| y.size}.max
	artist_space= audio_files.map{|f| f.artist}.map{|a| a.size}.max
	title_space = audio_files.map{|f| f.title}.map{|t| t.size}.max
	genre_space = audio_files.map{|f| f.genre}.map{|g| g.nil? ? 0 : g.size}.max
	
	#assumes pretty arrays have the same length
	audio_files.each{|f| puts "   "+f.pretty_print(year_space, artist_space, title_space, genre_space)}
end


def name2date(files)
	
	audio_files = AudioFactory.bulk_create(files)
	
	#get dates from filename
	name_dates = audio_files.map{|a| a.get_date_from_name(/19\d\d\-\d\d-\d\d/, /\d\d\-\d\d-19\d\d/) }

	#update dates in date tag
	audio_files.each do |a|
		
		#get dates from filename
		date = a.get_date_from_name(/19\d\d\-\d\d-\d\d/, /\d\d\-\d\d-19\d\d/)
		
		#do nothing if filename has no date...
		if date.nil?
			next
		end
		
		#if both have the same info update year
		if date.include? a.year
			a.year=date
			puts " ~ updated year tag to #{date} of file #{a.file_name}"
		elsif ARGS[:force]
			a.year=date
			puts " ~ forced updated year tag to #{date} of file #{a.file_name}"
		else
			puts " ~ Did nothing since current year tag is #{a.year} ... use --force option if you want to change if to #{date}"
		end
	end
end



def get_folder_audio_files
	return Dir.glob("*.*").select{|fn| fn =~ /.m4a$/ || fn =~ /.mp3$/ }
end

cd(ARGS[:folder])
all_files = get_folder_audio_files()

#search for audio files: ~mp3 and ~m4a

if ARGS[:list]
	# in current folder
	list3(all_files) 
	
	#change to sub folders
	Dir.glob("*").select{|f| File.directory? f}.each do |f|
		cd(File.join(ARGS[:folder], f))
		all_files = get_folder_audio_files()
		list3(all_files) 
	end
end

if ARGS[:contextdate]
	
	list3(all_files)
	audio_files = AudioFactory.bulk_create(all_files)
	
	#of the form title=> [audio_file, context_date1, context_date2]
	#if the title is repeated there is only one entrace #FIXME
	map = {}
	#only coun files that dont have a perfect date
	audio_files.reject{|a| a.full_date? }.each{|a| map[a.title]=[a]}
	
	if(ARGS[:verbose])
		puts " * Created a map of size [#{map.length}] with [#{audio_files.length}] files."
		puts " * #{map}" if map.length>0
	end
	
	cd("..")
	Dir.glob("*").reject{|f| f==ARGS[:folder]}.select{|f| File.directory? f}.each do |f|
		#enter context filder
		cd(f)
		
		context_audio = AudioFactory.bulk_create(get_folder_audio_files())
		#run the context audio files
		context_audio.each do |a| 
			#if the title of the context audio files is one that we're looking for7
			if not map[a.title].nil? 
				#and if the date of the song being updated is the same as a song in the current folder
				# and if that soung's context date is perfect: add it to map
				if map[a.title].length>=1 && a.full_date?
					map[a.title].push(a.year)
					if(ARGS[:verbose])
						puts " * Added #{a.year} to map[#{a.title}]"
					end
				end
			end
		end
		#exists context folder
		cd("..")
	end
	
	if(ARGS[:verbose])
		puts " * #{map}" if map.length>0
	end
	
	cd(ARGS[:folder])
	#check if map has some correct dates taken from context
	#if so, add them to the object
	#do nothing if there are two different dates
	map.each do |key, array|
		if array.uniq.length==1
			puts "No context dates were found for #{key}"
		elsif array.uniq.length>2
			puts "Several context dates were found: #{array[1..-1].join(", ")}"
			puts "... none used"
		else
			#OK!
			audio_file = array[0]
			context_year = array[1]
			old_year = audio_file.year
			audio_file.year=context_year
			puts "YES! Changed year to #{context_year} (old:#{old_year}) the file #{audio_file.title}"
		end
	end
end

	
	

if ARGS[:parsedate]
	name2date(all_files)
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

=begin
if __FILE__ == $0
  # Do something.. run tests, call a method, etc. We're direct.
end

begin #unneded se start uma funcao
  do_division_by_zero
rescue => exception
  puts exception.backtrace
end

# [*items] converts a single object into an array with that single object
# of converts an array back into, well, an array again
[*items].each do |item|
  # ...
end

h = { :age => 10 }
h[:name].downcase                         # ERROR
h[:name].downcase rescue "No name"        # => "No name"
=end

