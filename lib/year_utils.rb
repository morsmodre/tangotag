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
  # nil is returned if none or more than one option is needed
  def choose_year(year_list)
    # Check there are more then one full_year or year option
    all_full_years = year_list.uniq.map{|y| if full_year?(y) then y end}.compact
    all_short_years = year_list.uniq.map{|y| unless full_year?(y) then y end}.compact

    if year_list.empty?
      @log.warn('No possible years found!')
      nil
    elsif year_list.uniq.size==1 #one unique result
      year_list.first

    elsif all_full_years.size == 1 and
          all_short_years.size == 1 and
          year_in_full_year?(all_short_years.first, all_full_years.first)
      # If only one full and one short year exits and the full year is the year
      return all_full_years.first

    else
      @log.warn("Several possible years were found: #{year_list[0..-1].join(", ")}")
      nil
    end
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

end #YearUtils

