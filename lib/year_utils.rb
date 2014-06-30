# encoding: utf-8

require 'rubygems'
require 'taglib'
require 'log4r'

include Log4r

Encoding.default_internal = 'UTF-8'
Encoding.default_external = 'UTF-8'

# Utils to manipulate and do things with years
class YearUtils

  include Singleton

  def initialize
    @log = Logger.new 'YearUtils'
    @log.outputters = Outputter.stdout
    @log.level=FATAL
  end

  def verbose(activate)
    if activate
      @log.level=DEBUG
    end
  end


  # Choose a year according to the possibilities
  # nil is returned if none is found
  def choose_year(year_list, year_in_file=nil)

    if year_list.empty?
      @log.warn('No possible years found!')
      return nil
    end

    # Pre-process the list in order to remove repeated values
    compressed_list = compress_list(year_list)
    # Further process list to chose the value that fits the current year in the file
    compressed_list = choose_from_year_file(compressed_list, year_in_file)

    if compressed_list.size==1 #one unique result
      compressed_list.first
    end

    possibilities = compressed_list.join("  ")
    @log.warn("Several possible years were found: #{possibilities}")
    possibilities
  end

  def year_in_full_year?(y, fy)
    Regexp.new("^#{y}") =~ fy #compare ^year with full year
    not $&.nil?
  end

  def full_year?(year)
    if year.nil?
      return false
    end

    split_date = year.split('-')
    split_date.length==3 &&
        split_date[0].length==4 &&
        split_date[1].length==2 &&
        split_date[2].length==2
  end

  ## Compresses the given year_list in order to remove repeated values and
  # short_year values that have a full_year values to match.
  def compress_list(year_list)
    year_list.uniq.map{|y| unless small_year_in_list?(y, year_list) then y end}.compact
  end

  ## Further compress the list choosing only the elements that mach the year
  # This is euristic: the year is given by the file
  def choose_from_year_file(year_list, file_year)
    #do nothing if file_year is nil
    if file_year.nil? or year_list.length==1
      return year_list
    end

    chosen_list = year_list.uniq.map{|y| if y.include? file_year then y end}.compact
    if chosen_list.empty?
      year_list
    else
      chosen_list
    end
  end

  ## checks if the small_year is in some of the elements of the list with exception of himself
  def small_year_in_list?(small_year, year_list)
    for y in year_list
      if not small_year==y and y.include? small_year
        return true
      end
    end
    false
  end

end #YearUtils

