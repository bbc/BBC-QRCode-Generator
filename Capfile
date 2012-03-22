load 'deploy' if respond_to?(:namespace) # cap2 differentiator

# Add RVM's lib directory to the load path.
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

load 'config/deploy' # remove this line to skip loading any of the default tasks
require 'bundler/capistrano'
require "rvm/capistrano"

default_environment["TERM"] = 'xterm'
