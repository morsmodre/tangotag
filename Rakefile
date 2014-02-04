require 'rake/testtask'
require 'pp'

task :default => [:test]

desc "Test task"
Rake::TestTask.new do |test|
  test.pattern = 'test/test_*.rb'
end



#desc "Test task"
##task :test => [:dependent, :tasks] do
#task :test 	do
#  ruby 'test/test_audio_get.rb'
#  ruby 'test/test_audio_set.rb'
#  ruby 'test/test_navigator.rb'
#  #testrb test/
#end

