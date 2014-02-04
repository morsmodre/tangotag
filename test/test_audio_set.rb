require 'test/unit'

require_relative '../lib/audio'
#relative according to this file

include Log4r


class AudioSetTest < Test::Unit::TestCase

  def initialize(name)
    super(name)
    @log = Logger.new 'AudioFileLogger'
    @log.outputters = Outputter.stdout
  end


  # Change folder to the test/data folder  where the audio files are;
  # and makes a ax files to be changed by tests.
  def setup
    Dir.chdir(Dir.pwd+'/test/data/audio/')
    FileUtils.cp('a3.mp3', 'tmp.mp3')
    FileUtils.cp('b3.m4a', 'tmp.m4a')
  end

  # Go back to the default folder and erase the tmp files.
  def teardown
    FileUtils.rm('tmp.mp3')
    FileUtils.rm('tmp.m4a')
    Dir.chdir('../../..')
  end

  # At first tmp.mp3 doesn't have a year tag value. This test
  # first edits the year there is no year in the file. Then
  # it edits the year when there is a year tag present.
  def test_set_year_mp3
    Mp3File.new('tmp.mp3').year = '1936'
    assert_equal('1936', Mp3File.new('tmp.mp3').year)
    Mp3File.new('tmp.mp3').year = '1937-10-02'
    assert_equal('1937-10-02', Mp3File.new('tmp.mp3').year)
  end

  def test_set_year_m4a
    Mp4File.new('tmp.m4a').year = '1941'
    assert_equal('1941', Mp4File.new('tmp.m4a').year)
    Mp4File.new('tmp.m4a').year = '1941-10-02'
    assert_equal('1941-10-02', Mp4File.new('tmp.m4a').year)
  end

=begin
  def test_set_artist_mp3
    Mp3File.new('tmp.mp3').artist = 'Biagi'
    assert_equal('Biagi', Mp3File.new('tmp.mp3').artist)
    Mp3File.new('tmp.mp3').artist = 'Troilo'
    assert_equal('Troilo', Mp3File.new('tmp.mp3', false).artist)
  end

  def test_set_artist_m4a
    Mp4File.new('tmp.m4a').artist = 'Donato'
    assert_equal('Donato', Mp4File.new('tmp.m4a').artist)
    Mp4File.new('tmp.m4a').artist = 'Varela'
    assert_equal('Varela', Mp4File.new('tmp.m4a ', false).artist)
  end

  def test_set_title_mp3
    Mp3File.new('tmp.mp3').title = 'El Rapido'
    assert_equal('El Rapido', Mp3File.new('tmp.mp3').title)
    Mp3File.new('tmp.mp3').title = 'Arrabal'
    assert_equal('Arrabal', Mp3File.new('tmp.mp3', false).title)
  end

  def test_set_title_m4a
    Mp4File.new('tmp.m4a').title = 'Las Violetas'
    assert_equal('Las Violetas', Mp4File.new('tmp.m4a').title)
    Mp4File.new('tmp.m4a').title = 'El Flete'
    assert_equal('El Flete', Mp4File.new('tmp.m4a ', false).title)
  end

  def test_set_genre_mp3
    Mp3File.new('tmp.mp3').genre = 'Milonga'
    assert_equal('Milonga', Mp3File.new('tmp.mp3').genre)
    Mp3File.new('tmp.mp3').genre = 'Vals'
    assert_equal('Vals', Mp3File.new('tmp.mp3', false).genre)
  end

  def test_set_genre_m4a
    Mp4File.new('tmp.m4a').genre = 'Tango'
    assert_equal('Tango', Mp4File.new('tmp.m4a').genre)
    Mp4File.new('tmp.m4a').genre = 'Vals'
    assert_equal('Vals', Mp4File.new('tmp.m4a ', false).genre)
  end
=end

end #AudioSetTest