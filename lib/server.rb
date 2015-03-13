require 'rubygems'
require 'rack'
require 'sinatra'
require 'webrick'
require 'logger'
require 'json'
require File.expand_path(File.dirname(__FILE__)) + '/update'
require File.expand_path(File.dirname(__FILE__)) + '/node'

# Global vars
LOGDIR		      = File.expand_path(File.dirname(__FILE__)) + '/../logs'
LOGFILE         = LOGDIR + '/jenkins_webhook.log'
unless File.exists? LOGDIR
  Dir.mkdir LOGDIR
end

# Reset some envs
ENV['HOME']     = '/root'
ENV['PATH']     = '/sbin:/usr/sbin:/bin:/usr/bin:/opt/puppet/bin'
ENV['RACK_ENV'] = 'production' 

# Implement an access log for robust logging of user info and access and git output 
LOG = Logger.new(LOGFILE)

# Server options
opts = {
     :Port               => '1015',
     :Logger             => WEBrick::Log::new(LOGFILE, WEBrick::Log::DEBUG),
     :ServerType         => WEBrick::Daemon,
     :SSLEnable          => false,
}

class Server < Sinatra::Base

  post '/deploy' do
      request.body.rewind
      options = JSON.parse(request.env["rack.input"].read) 
      Update::Version.new(options)
      Update::Node.new(options)
  end
	
  not_found do
		halt 404, 'You shall not pass! (page not found)'
	end
end

Rack::Handler::WEBrick.run(Server, opts) do |server|
	[:INT, :TERM].each { |sig| trap(sig) { server.stop } }
end

