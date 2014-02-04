require 'test/unit'

require_relative '../lib/audio'
#relative according to this file

include Log4r


class AudioGetTest < Test::Unit::TestCase

  def initialize(name)
    super(name)
    @log = Logger.new 'AudioFileLogger'
    @log.outputters = Outputter.stdout
  end


  # Change folder to the test/data folder
  # where the audio files are.
  def setup
    Dir.chdir(Dir.pwd+'/test/data/audio/')
  end

  # Go back to the default folder.
  def teardown
    Dir.chdir('../../..')
  end

  def test_get_year_mp3
    assert_equal('1935',       Mp3File.new('a1.mp3').year)
    assert_equal('1935-02-14', Mp3File.new('a2.mp3').year)
    assert_nil(Mp3File.new('a3.mp3').year)
  end

  def test_get_year_m4a
    assert_equal('1941',       Mp4File.new('b1.m4a').year)
    assert_equal('1941-12-25', Mp4File.new('b2.m4a').year)
    assert_nil(Mp4File.new('b3.m4a').year)
  end


  def test_get_artist_mp3
    assert_equal('artist_a1', Mp3File.new('a1.mp3').artist)
    assert_nil(Mp3File.new('a3.mp3').artist)
  end

  def test_get_artist_m4a
    assert_equal('artist_b1', Mp4File.new('b1.m4a').artist)
    assert_nil(Mp4File.new('b3.m4a').artist)
  end

  def test_get_title_mp3
    assert_equal('title_a1', Mp3File.new('a1.mp3').title)
    assert_nil(Mp3File.new('a3.mp3').title)
  end

  def test_get_title_m4a
    assert_equal('title_b1', Mp4File.new('b1.m4a').title)
    assert_nil(Mp4File.new('b3.m4a').title)
  end

  def test_get_genre_mp3
    assert_equal('Tango', Mp3File.new('a1.mp3').genre)
    assert_nil(Mp3File.new('a3.mp3').genre)
  end

  def test_get_genre_m4a
    assert_equal('Milonga', Mp4File.new('b2.m4a').genre)
    assert_nil(Mp4File.new('b3.m4a').genre)
  end


  def test_full_date_mp3
    assert_equal(false, Mp3File.new('a1.mp3').full_date?)
    assert_equal(true,  Mp3File.new('a2.mp3').full_date?)
    assert_equal(false, Mp3File.new('a3.mp3').full_date?)
  end

  def test_full_date_m4a
    assert_equal(false, Mp4File.new('b1.m4a').full_date?)
    assert_equal(true,  Mp4File.new('b2.m4a').full_date?)
    assert_equal(false, Mp4File.new('b3.m4a').full_date?)
  end

  def test_pretty_print_mp3
    assert_equal('1935 artist_a1 title_a1 Tango  a1.mp3',
                 Mp3File.new('a1.mp3').to_s)
    assert_equal('1935-02-14 artist_a2 title_a2 Vals  a2.mp3',
                 Mp3File.new('a2.mp3').to_s)
    assert_equal("#{Mp3File.NO_YEAR} #{Mp3File.NO_ARTIST} #{Mp3File.NO_TITLE} #{Mp3File.NO_GENRE}  a3.mp3",
                 Mp3File.new('a3.mp3').to_s)

    assert_equal(Mp3File.new('a2.mp3').to_s,
                 Mp3File.new('a2.mp3').pretty_print(0,0,0,0))

    assert_equal('1935-02-14   artist_a2  title_a2   Vals   a2.mp3',
                 Mp3File.new('a2.mp3').pretty_print(12,10,10,5))
  end

  def test_pretty_print_m4a
    assert_equal('1941 artist_b1 title_b1 Tango  b1.m4a',
                 Mp4File.new('b1.m4a').to_s)
    assert_equal('1941-12-25 artist_b2 title_b2 Milonga  b2.m4a',
                 Mp4File.new('b2.m4a').to_s)
    assert_equal("#{Mp3File.NO_YEAR} #{Mp3File.NO_ARTIST} #{Mp3File.NO_TITLE} #{Mp3File.NO_GENRE}  b3.m4a",
                 Mp4File.new('b3.m4a').to_s)

    assert_equal(Mp4File.new('b2.m4a').to_s,
                 Mp4File.new('b2.m4a').pretty_print(0,0,0,0))

    assert_equal('1941-12-25   artist_b2   title_b2   Milonga   b2.m4a',
                 Mp4File.new('b2.m4a').pretty_print(12,11,10,8))
  end

end #AudioGetTest