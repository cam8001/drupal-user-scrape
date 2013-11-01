require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'crack'
  t.test_files = FileList['tc_*']
  t.verbose = true
end

task :default => [:test]
