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
    #folder for context date tests
    Dir.chdir(Navigator.BASE_DIR+'/test/data/action/contextdate/a')
    #copy a file to be changed in tests and deleted in the end
    FileUtils.cp('a1.mp3', 'x1.mp3')
    FileUtils.cp('a2.mp3', 'x2.mp3')
    FileUtils.cp('a3.mp3', 'x3.mp3')
    FileUtils.cp('a4.mp3', 'x4.mp3')
    FileUtils.cp('a5.mp3', 'x5.mp3')
  end

  # Go back to the default folder.
  def teardown
    FileUtils.remove_file('x1.mp3', true)
    FileUtils.remove_file('x2.mp3', true)
    FileUtils.remove_file('x3.mp3', true)
    FileUtils.remove_file('x4.mp3', true)
    FileUtils.remove_file('x5.mp3', true)
    super
  end


  def test_get_possible_years_by_title
    action = ActionSetDateByContext.new
    dates_found = action.get_possible_years_by_title 'a1.mp3'
    assert_equal(4, dates_found.size)
    assert_equal('1942',       dates_found[0])
    assert_equal('1942-09-10', dates_found[1])
    assert_equal('1942-09-10', dates_found[2])
    assert_equal('1979-01-01', dates_found[3])
  end

  # Changes the year of the x.mp3 file according to the context in contextdate/b folder files
  def test_action_set_date_context
    action = ActionSetDateByContext.new
    aux_file = 'x2.mp3'
    assert_equal('1935', AudioFactory.create(aux_file).year)
    #assert_equal('1935-02-14', AudioFactory.create(aux_file).year)
    action.change_year aux_file
    assert_equal('1941-12-31', AudioFactory.create(aux_file).year)
  end

  # Context year does not change since there are several options
  def test_action_several_context_dates
    action = ActionSetDateByContext.new
    aux_file = 'x1.mp3'
    assert_equal('1982-09-10', AudioFactory.create(aux_file).year)
    action.change_year aux_file
    assert_equal('1982-09-10', AudioFactory.create(aux_file).year)
  end

  # Context year does not change since there are several options (other and the same)
  def test_action_several_context_dates_and_same_date
    action = ActionSetDateByContext.new
    aux_file = 'x4.mp3'
    assert_equal('1941-11-22', AudioFactory.create(aux_file).year)
    action.change_year aux_file
    assert_equal('1941-11-22', AudioFactory.create(aux_file).year)
  end

  # Context year does not change since there are several options (other and the same)
  def test_context_date_is_changes_when_title_has_signs_and_upper_case_and_not_trimed_with_coma
    action = ActionSetDateByContext.new
    aux_file = 'x3.mp3'
    assert_equal('1941-01-02', AudioFactory.create(aux_file).year)
    action.change_year aux_file
    assert_equal('1941-11-22', AudioFactory.create(aux_file).year)
  end

  # When several options exist, if the file has a yyyy year and it fits one of the options, choose that option
  def test_context_choice_is_the_yyyy_year_unknown_file
    action = ActionSetDateByContext.new
    aux_file = 'x5.mp3'
    assert_equal('1938', AudioFactory.create(aux_file).year)
    action.change_year aux_file
    assert_equal('1938-11-22', AudioFactory.create(aux_file).year)
  end

end #ActionSetDateByContextTest
