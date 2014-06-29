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
  def choose_year(year_list)
    # Check there are more then one full_year or year option
    all_full_years = year_list.uniq.map{|y| if full_year?(y) then y end}.compact
    all_short_years = year_list.uniq.map{|y| unless full_year?(y) then y end}.compact

    if year_list.empty?
      @log.warn('No possible years found!')
      return nil
    end

    # Pre-process the list in order to remove repeated values
    compressed_list = compress_list(year_list)

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

