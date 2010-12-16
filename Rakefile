require 'rubygems'
require 'bundler'

Bundler.setup

Dir['tasks/*.rb'].each { |file| load(file) }
GithubGem::RakeTasks.new(:gem)

task :default => [:spec]
