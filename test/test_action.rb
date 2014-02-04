require 'test/unit'

require_relative '../lib/actions'
require_relative '../lib/navigator'
#relative according to this file


class ActionBaseTest < Test::Unit::TestCase

  # Change folder to action test data folder
  def setup
    Dir.chdir(Navigator.BASE_DIR+'/test/data/action/a')
  end

  # Go back to the default folder.
  def teardown
    Dir.chdir(Navigator.BASE_DIR)
  end
end

class ActionListTest < ActionBaseTest

  def test_action_list
    expected_list = [
        '   1982-09-10 Biagi     Indiferencia Tango    a1.mp3',
        "   1935-02-14 D'Arienzo Mi Dolor     Tango    a2.mp3",
        '   ?YEAR?     ?ARTIST?  ?TITLE?      ?GENRE?  a3.mp3'].join("\n")

    action = ActionList.new
    printed_list = action.do(Navigator.instance.get_folder_audio_files)
    assert_equal(expected_list , printed_list)
  end
end #ActionListTest


class ActionSetDateByContextTest < ActionBaseTest

  # Change folder to action test data folder
  def setup
    super
    #copy a file to be changed in tests and deleted in the end
    FileUtils.cp('a1.mp3', 'x.mp3')
  end

  # Go back to the default folder.
  def teardown
    FileUtils.remove_file('x.mp3', true)
    super
  end


  def test_get_possible_years_by_title
    action = ActionSetDateByContext.new
    dates_found = action.get_possible_years_by_title 'a1.mp3'
    assert_equal(3, dates_found.size)
    assert_equal('1942',       dates_found[0])
    assert_equal('1942-09-10', dates_found[1])
    assert_equal('1942-09-10', dates_found[2])
  end

  # Changes the year of the x.mp3 file according to the context in action/b folder files
  def test_action_set_date_context
    action = ActionSetDateByContext.new
    assert_equal('1982-09-10', AudioFactory.create('x.mp3').year)
    action.change_year 'x.mp3'
    assert_equal('1942-09-10', AudioFactory.create('x.mp3').year)
  end

end #ActionSetDateByContextTest
