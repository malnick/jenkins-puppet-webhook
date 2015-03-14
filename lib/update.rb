#!/bin/env ruby

begin
  
  require 'rubygems'
  require 'logger'
  require 'json'
  require 'yaml'
  require 'optparse'
  require 'git'
  require 'fileutils'

  # Require all my libs
  library_files = Dir[File.join(File.dirname(__FILE__), "*.rb")].sort
  library_files.each do |f|
    require f
  end

rescue Exception => e
  
  puts "Failure during requires in update.rb"
  puts e.message

end

# Global vars
LOGDIR          = File.expand_path(File.dirname(__FILE__)) + '/../logs'
LOGFILE         = LOGDIR + '/jenkins_webhook.log'

unless File.exists? LOGDIR
  Dir.mkdir LOGDIR
end
