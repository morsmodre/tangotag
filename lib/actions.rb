# encoding: utf-8

require 'rubygems'
require 'taglib'
require 'nokogiri'
require 'open-uri'
require 'pp'

require_relative 'audio'
require_relative 'year_utils'
require_relative 'discographies'

Encoding.default_internal = 'UTF-8'
Encoding.default_external = 'UTF-8'


class Action
  ERROR = 'SYSTEM ERROR: Cannot be called by Action Class'

  def initialize(log_exists=true)
    @log = Logger.new self.class.name.to_s
    @log.outputters = Outputter.stdout if log_exists
  end

  def do(*args); raise ERROR; end
end


class ActionList < Action

  def do(files)
    audio_files = AudioFactory.bulk_create(files)

    len_year   = audio_files.map{|f| f.year  }.map{|y| y.nil? ? AudioFile.NO_YEAR.size   : y.size}.max
    len_artist = audio_files.map{|f| f.artist}.map{|a| a.nil? ? AudioFile.NO_ARTIST.size : a.size}.max
    len_title  = audio_files.map{|f| f.title }.map{|t| t.nil? ? AudioFile.NO_TITLE.size  : t.size}.max
    len_genre  = audio_files.map{|f| f.genre }.map{|g| g.nil? ? AudioFile.NO_GENRE.size  : g.size}.max

    #string with the listing
    list_string = audio_files.map{|f| '   '+f.pretty_print(len_year, len_artist, len_title, len_genre)}.join("\n")

    #prints and returns the string with the listings
    puts list_string
    list_string
  end

end #ActionList


class ActionSetDateByContext < Action

  # Get the non nils years in context whose files have the same title
  def get_possible_years_by_title(file)
    file_title = AudioFactory.create(file).title

    possible_years = []
    Navigator.instance.in_sibling_folders do
      # For each siblings directory search the files with the same title
      Navigator.instance.in_audio_files do |f|
        # If titles are equal and the context file has a year, add the year
        if not f.title.nil? and not f.year.nil? and same_title(file_title, f.title)
          possible_years << f.year
        end
      end
    end
    possible_years
  end

  ## Checks if s1 and s2 are the same string, even if latin character differ.
  def same_title(s1, s2)
    latin =	 'ÀÁÂÃàáâãÇçÈÉÊèéêÌÍìíÑñÒÓÕòóõÙÚùúü'
    normal = 'AAAAaaaaCcEEEeeeIIiiNnOOOoooUUuuu'
    s1.tr(latin, normal).casecmp(s2.tr(latin, normal))==0
  end

  # Sets the date of the argument file according to the title of the context files.
  # The context files are those in all siblings folders.
  def change_year(file, no=false)
    possible_years = get_possible_years_by_title(file)
    year_choice = YearUtils.instance.choose_year(possible_years)

    # puts "Choice: #{year_choice}\tpossibilities #{possible_years}" should be logged!

    file = AudioFactory.create(file)
    if year_choice.nil?
      puts " * No year option found for #{file.title}"
    else
      if not no
        file.year=year_choice
      end
      puts "   Found new year = #{year_choice} for #{file.title}"
    end
  end

  def do(files, no=false)
    files.each {|f| change_year(f, no)}
  end

end #ActionSetDateByContext


class ActionNokogiri < Action

  def do(files, nokogiri, no=false)

    doc = Nokogiri::HTML(open(Discography.map_resources[nokogiri]))

    if doc.nil?
      puts "*** The discography for #{nokogiri} does not exists! ***"
      return
    end

    files = AudioFactory.bulk_create(files)

    #only count files that dont have a perfect date
    files.reject{|a| a.full_date? }.each do |a|

      #Processes the title to fit the html:
      # - downcase it
      # - remove the latin characters from song title
      # This must happen since xpath is extremely picky and will not catch uppercase differences
      latin =	 'ÀÁÂÃàáâãÇçÈÉÊèéêÌÍìíÑñÒÓÕòóõÙÚùúü'
      normal = 'AAAAaaaaCcEEEeeeIIiiNnOOOoooUUuuu'
      uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      downcase  = 'abcdefghijklmnopqrstuvwxyz'

      processed_title = a.title.downcase.tr(latin, normal)

      xpath = "//a[translate(.,'#{latin}#{uppercase}','#{normal}#{downcase}')='#{processed_title}']/../../td[4]"
      ## puts " * #{xpath}" #logit

      dates = doc.xpath(xpath).map {|link| link.content.to_s}

      dates.uniq!

      if dates.length == 0
        puts " * No dates found for title #{a.title.capitalize}"
      elsif dates.length>1
        puts " * Too many dates found for #{a.title.capitalize} :: #{dates.join(" ; ")}"
      elsif dates.length==1
        date = dates.first.split(".").reverse.join("-")
        if a.year==date
          puts " ! Year is kept the same: #{date}"
        else
          puts "   Filling year=#{date} --> #{a.title.capitalize}"
          if not no
            a.year = date
          end
        end
      end
    end

  end

end #ActionSetDateByContext


class ActionTitle2Date < Action

  def do(files, no=false)

    files = AudioFactory.bulk_create(files)

    #only count files that dont have a perfect date
    files.reject{|f| f.full_date? }.each do |f|

      ## pattern is (DD-MM-19YY)
      #Regexp.new("#{f.title}") =~ /\d\d-\d\d-19\d\d/
      f.title =~ /\d\d-\d\d-19\d\d/

      if not $~.nil? # if not match
        found_year = $~.to_s.split('-')
        found_year.reverse!
        found_year =  found_year.join('-')
        puts "   Match #{$~}! year=#{found_year} set in #{f.title}"
      end


      if not no
        f.year = found_year unless found_year.nil? # unless because the found_year is not defined is no match exists
      end

    end
  end


  def get_date_from_name(*patterns)
    matches = patterns.map do |p|

      file_name =~ p #match

      if $~.nil?
        next nil
      else
        #found a pattern: place it in the YYYY-MM-DD form if needed
        pieces = $~.to_s.split('-')

        if pieces[0].length!=4
          pieces.reverse!
        end

        next pieces.join('-')
      end
    end

    matches.compact!

    raise "\tMore then one match of date in filename!!" if matches.uniq.length>1

    matches[0] #if no match => nil
  end

end #ActionTitle2Date


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

