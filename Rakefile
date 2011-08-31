require 'rake/testtask'

desc "Run unit tests"
task :test do
  Rake::TestTask.new
end

desc "Clear cache"
task :clear_cache do
  system "rm -rf /tmp/rack"
end

task :default => 'test'

