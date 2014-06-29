# encoding: utf-8

require 'test/unit'

require_relative '../lib/navigator'
#relative according to this file

include Log4r


class NavigatorTest < Test::Unit::TestCase

  # Go to the home folder
  def setup
    Dir.chdir('c:/git/tangotag')
  end

  # Go back to the default folder.
  def teardown
    Dir.chdir('c:/git/tangotag')
  end

  def test_pwd
    navigator = Navigator.instance #cannot call new in singleton
    navigator.pwd
    # Check if directory is not changed
    assert_equal('c:/git/tangotag', Dir.pwd.to_s)
  end

  def test_cd_dir_one
    navigator = Navigator.instance #cannot call new in singleton
    navigator.cd('test')
    # Check if directory is not changed
    assert_equal('c:/git/tangotag/test', Dir.pwd.to_s)
  end

  def test_cd_dir_two
    navigator = Navigator.instance #cannot call new in singleton
    navigator.cd('test/data')
    assert_equal('c:/git/tangotag/test/data', Dir.pwd.to_s)
  end

  def test_cd_dir_not_there
    navigator = Navigator.instance #cannot call new in singleton
    navigator.cd('tango')
    assert_equal('c:/git/tangotag', Dir.pwd.to_s)
  end

  def test_get_audio_files
    Dir.chdir('c:/git/tangotag/test/data/audio')
    navigator = Navigator.instance
    files = navigator.get_folder_audio_files
    assert_equal(files.size, 6)
    assert_equal(files[0], 'a1.mp3')
    assert_equal(files[1], 'a2.mp3')
    assert_equal(files[2], 'a3.mp3')
    assert_equal(files[3], 'b1.m4a')
    assert_equal(files[4], 'b2.m4a')
    assert_equal(files[5], 'b3.m4a')
  end

  def test_in_audio_files
    Dir.chdir('c:/git/tangotag/test/data/audio')
    navigator = Navigator.instance
    aux_string = 'F: '
    navigator.in_audio_files do |f|
      aux_string << f.file_name << ','
    end
    assert_equal('F: a1.mp3,a2.mp3,a3.mp3,b1.m4a,b2.m4a,b3.m4a,', aux_string)
  end

  def test_get_sibling_folders
    Dir.chdir('c:/git/tangotag/test/data/action/contextdate/a')
    navigator = Navigator.instance
    sibling_folders = navigator.get_sibling_folders
    assert_equal(1, sibling_folders.size)
    assert_equal('b', sibling_folders[0])
    #back to current dir is working too
    assert_equal('c:/git/tangotag/test/data/action/contextdate/a', Dir.pwd.to_s)
  end

  def test_in_sibling_folders
    Dir.chdir('c:/git/tangotag/test/data/action/contextdate/a')
    navigator = Navigator.instance
    aux_string = 'F: '
    navigator.in_sibling_folders do
      aux_string << File.basename(Dir.getwd).to_s << ','
    end
    assert_equal('F: b,', aux_string)
  end
end #NavigatorTest