# encoding: utf-8

#particles not to be capitalized
PARTICLES = ['con']


=begin
def camelize(files)
	files.each do|file_name| 
		TagLib::FileRef.open(file_name) do |audio_file|
			
			### change artist
			artist = audio_file.tag.artist  
			
			#capitalize all words in the name 
			capital_words= artist.split(' ').map {|w| w.capitalize }
			#downcase those that are particles
			ok_words= capital_words.map{|w| if PARTICLES.include? w.downcase then w.downcase else w end } 
			
			new_artist = ok_words.join(' ')
			
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
			
			new_title = ok_words.join(' ')
			
			
			audio_file.tag.artist = new_artist
			audio_file.tag.title = new_title
			audio_file.save()
		end
	end
end
=end

=begin
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
=end

=begin
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
=end


#artists array to build the map of all possibilities
#puts artists_array.uniq.map{|s| "\"#{s.force_encoding('utf-8')}\" => "}

def get_folder_audio_files
	return Dir.glob('*.*').select{|fn| fn =~ /.m4a$/ || fn =~ /.mp3$/ }
end

cd(ARGS[:folder])
all_files = get_folder_audio_files()

#search for audio files: ~mp3 and ~m4a

if ARGS[:list]
	# in current folder
	list3(all_files) 
	
	#change to sub folders
	Dir.glob('*').select{|f| File.directory? f}.each do |f|
		cd(File.join(ARGS[:folder], f))
		all_files = get_folder_audio_files()
		list3(all_files) 
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

unless ARGS[:tclean].nil? && ARGS[:tclean]!=0
  longest_tclean= ARGS[:tclean].map { |x| x.size }.max
  ARGS[:tclean].each { |w| puts "Removing #{w.ljust(longest_tclean)} from titles ..." }
  ARGS[:tclean].each { |s| tclean(all_files, s) }
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

