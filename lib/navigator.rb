# encoding: utf-8

require 'singleton'
require 'log4r'

require_relative 'audio'

class Navigator

  @@BASE_DIR = 'c:/git/tangotag'
  def self.BASE_DIR() @@BASE_DIR  end

  def self.SET_BASE_DIR(dir)
    @@BASE_DIR=dir
  end

  include Singleton

  def initialize
    @log = Log4r::Logger.new 'Navigator'
    @log.outputters = Outputter.stdout
    @log.level=FATAL
  end

  def verbose(activate)
    if activate
      @log.level=DEBUG
    end
  end


  def pwd
    d = Dir.pwd
    @log.debug("pwd: #{d}")
  end

  def cd(dir)
    if Dir.exists?("#{dir}")
      Dir.chdir(dir)
      @log.debug "cd #{dir}"
    else
      @log.error("Cannot change to #{dir} because it doesn't exist")
    end
  end

  def get_folder_audio_files
    Dir.glob('*.*').select{|fn| fn =~ /.m4a$/ || fn =~ /.mp3$/ }
  end

  def in_audio_files
    get_folder_audio_files.each do |f|
      yield(AudioFactory.create(f))
    end
  end

  def get_sibling_folders
    # Get current directory name
    dir_name = Dir.getwd.split('/').last
    Dir.chdir('..')
    # Get names of siblings directories
    sibling_folders = Dir.glob('*').select{|f| File.directory? f}.reject{|f| f==dir_name}
    # go back to the file directory
    Dir.chdir(dir_name)
    sibling_folders
  end

  def in_sibling_folders
    current_dir = Dir.pwd
    sibling_folders = get_sibling_folders
    Dir.chdir('..')
    sibling_folders.each do |dir|
      Dir.chdir(dir)
      yield
      Dir.chdir('..')
    end
    Dir.chdir(current_dir)
  end

end #Navigator
