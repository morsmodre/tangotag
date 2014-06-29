# encoding: utf-8

require 'rubygems'
require 'optparse'
require 'ostruct'
require 'pp'

Encoding.default_internal = 'UTF-8'
Encoding.default_external = 'UTF-8'


class Args

  def self.parse(args)

    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new

    #set defaults here
    options.folder = '.'
    options.list = false

    options.date_it = false
    options.title2year = false
    options.nokogiri = nil

    options.no = false


    opt_parser = OptionParser.new do |opts|

      opts.banner = "Usage: #{$0} -f <folder>"

      opts.separator ""
      opts.separator "Specific options:"


      ## Compulsory options
      opts.on('--folder FOLDER',
              'The folder where the files modification will happen') do |folder|
        options.folder = folder.encode('utf-8', 'iso-8859-1')
      end


      ## Read options

      opts.on('-l', '--list',
              'List artist tag in the folders files before doing anything else') do |list|
        options.list = true
      end


      #Write options

      opts.on('--contextdate',
              'Sets the date of the files according to the context, i.e., the files in the sibling folders. If the date is already in the form YYYY-MM-DD does nothing.') do |list|
        options.date_it = true
      end

      opts.on('--title2year',
              'Use the title to retrieve the year. Several patterns are tried.') do
        options.title2year = true
      end

      opts.on('--nokogiri ORCHESTRA',
              'Uses the discography files of the ORCHESTRA to find the dates of the files in FOLDER.') do |orchestra|
        options.nokogiri = orchestra
      end

      ## Other options

      opts.on('--no',
              'Do not modify the files. This makes all other options run in trial only') do |list|
        options.no = true
      end

    end

    opt_parser.parse!(args)
    options #implicit return

  end  #parse()

end  # class Args




=begin
#where the args will go
ARGS = {}
#particles not to be capitalized
PARTICLES = ['con']

NOKOGIRI = {:biagi => 'D:/git/tangotag/biagi.html'}#"http://www.tango-dj.at/DJ-ing/collection/orchestras/Biagi.htm"}

OptionParser.new do |opts|
	opts.banner = "Usage: #{$0} -f <folder>"

	opts.on('-f', '--folder FOLDER',
          'The folder where the files modification will happen') do |folder|
		ARGS[:folder] = folder.encode('utf-8', 'iso-8859-1')
	end


	ARGS[:verbose] = false
	opts.on('-v', '--verbose', 'Run verbosely') do |v|
		ARGS[:verbose] = v
	end

	ARGS[:verbose] = false
	opts.on('--force', 'Force action if some doubts appear') do |f|
		ARGS[:force] = f
	end


	opts.on('--list', 'List artist tag in the folders files') do |list|
		ARGS[:list] = list
	end

	opts.on('--parsedate', 'Parsed dates in the formats YYYY-MM-DD and DD-MM-YYYY and fills the date tag with that info',
          '  Use the force option to overide present year tag information.') do |parsedate|
		ARGS[:parsedate] = parsedate
	end

	opts.on('--contextdate', 'Add description.') do |contextdate|
		ARGS[:contextdate] = contextdate
	end

	opts.on('--nokogiri ORQUESTRA',
			[:biagi ], 'Add description.') do |orquestra|
		ARGS[:nokogiri] = NOKOGIRI[orquestra]
	end

	opts.on('--changedate YYYY-MM-DD', 'Changes the year tags to YYYY-MM-DD of the first file in the --folder.') do |new_date|
		ARGS[:changedate] = new_date
	end


	opts.on('--camelize', 'Changed the names to be in camel-case') do |camelize|
		ARGS[:camelize] = camelize
	end

	opts.on('--tclean x,y,z', Array, 'Clean the titles by removing the x,y,z strings from them.') do |list|
		ARGS[:tclean] = list.map {|x| x.encode('utf-8', 'iso-8859-1') }
	end

end.parse!

=end