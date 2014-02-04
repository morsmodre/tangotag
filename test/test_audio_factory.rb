require 'test/unit'

require_relative '../lib/audio'
#relative according to this file

include Log4r


class AudioFactoryTest < Test::Unit::TestCase

  def initialize(name)
    super(name)
    @log = Logger.new 'AudioFactoryLoggerTest'
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


  def test_create
    file = AudioFactory.create('a1.mp3')
    assert_kind_of(Mp3File, file)
    file = AudioFactory.create('b1.m4a')
    assert_kind_of(Mp4File, file)
  end

  def test_create_fail
    assert_raise RuntimeError do
      AudioFactory.create('no.txt') #, 'File type not supported: no.txt')
    end
  end

  def test_bulk_create
    files = AudioFactory.bulk_create(%w(a1.mp3 b1.m4a))
    assert_equal(2, files.size)
    assert_kind_of(Mp3File, files[0])
    assert_kind_of(Mp4File, files[1])
  end

end #AudioFactoryTest