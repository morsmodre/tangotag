# encoding: utf-8

require 'rubygems'
require 'taglib'
require 'optparse'
require 'nokogiri'
require 'open-uri'

require_relative 'args'
require_relative 'navigator'
require_relative 'actions'

Encoding.default_internal = 'UTF-8'
Encoding.default_external = 'UTF-8'


def do_action_list
  action = ActionList.new
  action.do Navigator.instance.get_folder_audio_files
  puts ''
end

def do_action_date_it(no=false)
  all_files = Navigator.instance.get_folder_audio_files
  action = ActionSetDateByContext.new
  action.do(all_files, no)
end

def do_nokogiri(nokogiri, no=false)
  all_files = Navigator.instance.get_folder_audio_files
  action = ActionNokogiri.new
  action.do(all_files, nokogiri, no)
end

def do_title2year(no=false)
  all_files = Navigator.instance.get_folder_audio_files
  action = ActionTitle2Date.new
  action.do(all_files, no)
end


if __FILE__ == $0
  #parse options
  options = Args.parse(ARGV)

  # set navigator dir
  Navigator.SET_BASE_DIR(options.folder)
  Navigator.instance.verbose(true)
  # go to that dir
  Navigator.instance.cd options.folder

  ## LIST ##
  if options.list
    do_action_list
  end


  if options.title2year
    do_title2year(options.no)
    puts ''
    do_action_list
  end

  if options.date_it
    do_action_date_it options.no
    puts ''
    do_action_list
  end

  if not options.nokogiri.nil?
    do_nokogiri(options.nokogiri, options.no)
    puts ''
    do_action_list
  end

end

exit 0
