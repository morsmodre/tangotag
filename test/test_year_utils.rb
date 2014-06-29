require 'test/unit'

require_relative '../lib/year_utils'

class YearUtilsTest < Test::Unit::TestCase

  # Change folder to the test/data folder
  # where the audio files are.
  def setup
#    Dir.chdir(Dir.pwd+'/test/data/action/a')
  end

  # Go back to the default folder.
  def teardown
#    Dir.chdir('../../../..')
  end

  def test_choose_year
    yu = YearUtils.instance
    #yu.verbose(true)
    assert_equal(nil,          yu.choose_year(%w()))
    assert_equal('1928',       yu.choose_year(%w(1928)))
    assert_equal('1928',       yu.choose_year(%w(1928 1928)))
    assert_equal('1928 1929',  yu.choose_year(%w(1928 1929))) #no choice can be done
    assert_equal('1941-03-04', yu.choose_year(%w(1941-03-04)))
    assert_equal('1941-03-04', yu.choose_year(%w(1941 1941-03-04))) #merge

    assert_equal('1942 1941-03-05',       yu.choose_year(%w(1942 1941 1941-03-05)))
    assert_equal('1942 1941-03-05',       yu.choose_year(%w(1942 1941-03-05 1941-03-05)))
    assert_equal('1942 1941-03-05',       yu.choose_year(%w(1942 1942 1941-03-05)))
    assert_equal('1942-12-31 1941-03-05', yu.choose_year(%w(1942-12-31 1941-03-05)))
    assert_equal('1941-03-05 1941-03-04', yu.choose_year(%w(1941-03-05 1941-03-04)))
  end

  def test_is_year_in_full_year
    yu = YearUtils.instance
    assert_equal(true,  yu.year_in_full_year?('1941','1941-03-04'))
    assert_equal(false, yu.year_in_full_year?('1942','1941-03-04'))
    assert_equal(false, yu.year_in_full_year?('1941','25-12-1941'))
  end

  def test_is_full_year
    yu = YearUtils.instance
    assert_equal(false, yu.full_year?(nil))
    assert_equal(false, yu.full_year?('1985'))
    assert_equal(false, yu.full_year?('1985-10'))
    assert_equal(false, yu.full_year?('1985/10/02'))
    assert_equal(true,  yu.full_year?('1985-10-02'))
    assert_equal(false, yu.full_year?('1985-10-02-000'))
    assert_equal(false, yu.full_year?('1985-10-02:000'))
  end

  def test_compress_list
    yu = YearUtils.instance
    assert_equal(%w(1930), yu.compress_list(%w(1930)))
    assert_equal(%w(1930-06-06), yu.compress_list(%w(1930-06-06)))
    assert_equal(%w(1926), yu.compress_list(%w(1926 1926)))
    assert_equal(%w(1930-06-06), yu.compress_list(%w(1930-06-06 1930-06-06)))
    assert_equal(%w(1926 1930-06-06), yu.compress_list(%w(1926 1930-06-06 1930-06-06)))

    assert_equal(%w(1930-06-06), yu.compress_list(%w(1930 1930-06-06)))
    assert_equal(%w(1930-06-06 1929-07-07), yu.compress_list(%w(1930 1930-06-06 1929 1929-07-07)))
  end

  def test_year_in_list
    yu = YearUtils.instance
    assert_equal(false, yu.small_year_in_list?('1930', %w(1930)))
    assert_equal(false, yu.small_year_in_list?('1930', %w(1930 1929-12-30)))
    assert_equal(false, yu.small_year_in_list?('1930', %w(1929 1929-12-30)))

    assert_equal(true,  yu.small_year_in_list?('1930', %w(1929 1930-12-31)))
    assert_equal(true,  yu.small_year_in_list?('1930', %w(1930-12-31)))
    assert_equal(true,  yu.small_year_in_list?('1930', %w(1930-12-30 1930-12-31)))
    assert_equal(true,  yu.small_year_in_list?('1930', %w(1930-12-30 1930-01-01)))
    assert_equal(true,  yu.small_year_in_list?('1930', %w(1930-12-30 1929-01-01)))
  end

end #YearUtilsTest
