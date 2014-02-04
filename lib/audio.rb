# encoding: utf-8

require 'rubygems'
require 'taglib'
require 'log4r'

require_relative 'year_utils'

Encoding.default_internal = 'UTF-8'
Encoding.default_external = 'UTF-8'

include Log4r


class AudioFile

  # Class variables and accessors: do not mess with this!
  @@NO_YEAR   = '?YEAR?'
  @@NO_ARTIST = '?ARTIST?'
  @@NO_TITLE  = '?TITLE?'
  @@NO_GENRE  = '?GENRE?'

  def self.NO_YEAR()   @@NO_YEAR   end
  def self.NO_ARTIST() @@NO_ARTIST end
  def self.NO_TITLE()  @@NO_TITLE  end
  def self.NO_GENRE()  @@NO_GENRE  end


  attr_reader :file_name

	def initialize(file_name, log_exists=false)
		#variable doesn't exist before this
		@file_name = file_name
    #define log
    @log = Logger.new 'AudioFile'
    @log.outputters = Outputter.stdout if log_exists
  end
	
	def artist
		unless @artist.nil? #if not
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
		unless @title.nil?
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
		unless @genre.nil?
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
    YearUtils.instance.full_year? year
	end
		
	#sizes for year, artist, title and genre
	def pretty_print(size1, size2, size3, size4)

    #if some of the parameters is nil, return a value
    year_s   = if !year.nil?   then year.to_s   else @@NO_YEAR   end
    artist_s = if !artist.nil? then artist.to_s else @@NO_ARTIST end
    title_s  = if !title.nil?  then title.to_s  else @@NO_TITLE  end
    genre_s  = if !genre.nil?  then genre.to_s  else @@NO_GENRE  end

    "#{year_s.ljust(size1)} #{artist_s.ljust(size2)} #{title_s.ljust(size3)} #{genre_s.ljust(size4)}  #{file_name}"
	end

  # <b>DEPRECATED:</b> Use the actions instead (I guess).
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

  def to_s
    pretty_print(0,0,0,0)
  end

end


class Mp3File < AudioFile
	
	def year
		unless @year.nil?
      return @year
    end

    TagLib::MPEG::File.open(file_name) do |mp3_file|

			tag = mp3_file.id3v2_tag
			if tag.nil?
				@log.error('No tag found in this file while calling year()!!!')
				return nil
			end
			
			if tag.frame_list('TDRC').empty?
        @log.warn('No year was found in mp3 file')
				return nil
			end

			return tag.frame_list('TDRC').first.field_list.first
		end
	end
	
	def year=(new_year)
		TagLib::MPEG::File.open(file_name) do |mp3_file| 
			
			tag = mp3_file.id3v2_tag
			if tag.nil?
				@log.error("No tag found in this file while calling year=#{new_year}!")
				return nil
      end

      #if a tdrc frame exists, remove it
      if tag.frame_list('TDRC').size == 1
        tag.remove_frame(tag.frame_list('TDRC').first)
        #tag.remove_frame('TDRC') #doesn't work :(
      end

      #make a new TDRC (year) frame with the new year and add it
      new_frame = TagLib::ID3v2::TextIdentificationFrame.new('TDRC', TagLib::String::UTF8)
      new_frame.text = new_year
      tag.add_frame(new_frame)

      mp3_file.save()
		end
		@year = new_year
	end
end

class Mp4File < AudioFile
	
	def year
		unless @year.nil?
      return @year
    end

    TagLib::MP4::File.open(file_name) do |mp4_file|
			item_list_map = mp4_file.tag.item_list_map

      if item_list_map.size == 0 or
         item_list_map['©day'].nil?
        @log.warn('No year was found in mp4 file')
        return nil
      end

			item_list_map['©day'].to_string_list.first
		end
	end
	
	def year=(new_year)
		TagLib::MP4::File.open(file_name) do |mp4_file|
			item_list_map = mp4_file.tag.item_list_map

      #replaces or adds previous "©day" value
			item_list_map.insert('©day', TagLib::MP4::Item.from_string_list([new_year]))
			mp4_file.save()
		end
		@year = new_year
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

  def self.bulk_create(file_name_list)
    return file_name_list.map {|f| AudioFactory.create(f)}
  end


	def self.mp3? #private
		return @file_name =~ /.mp3$/
	end

	def self.mp4? #private
		return @file_name =~ /.m4a$/
	end

  private_class_method :mp3?, :mp4?

end
	
