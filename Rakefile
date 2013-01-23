require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.pattern = 'test/{minitest_helper,unit/**/*}.rb'
  t.verbose = true
end

Rake::TestTask.new("test:integration") do |t|
  t.libs.push "lib"
  t.pattern = 'test/integration/**/*.rb'
  t.verbose = true
end

task default: :test
