require 'rubygems'
require 'rack'
require 'sinatra'
require 'webrick'
require 'logger'
require File.expand_path(File.dirname(__FILE__)) + '/update'

# Reset some envs
ENV['HOME']     = '/root'
ENV['PATH']     = '/sbin:/usr/sbin:/bin:/usr/bin:/opt/puppet/bin'
ENV['RACK_ENV'] = 'production' 

LOG = Logger.new(LOGFILE)

# Server options
opts = {
     :Port               => '1015',
     :Logger             => WEBrick::Log::new(LOGFILE, WEBrick::Log::DEBUG),
     :ServerType         => WEBrick::Daemon,
     :SSLEnable          => false,
}

class Server < Sinatra::Base

  # Deploy static content (no git updates for control repo)
  post 'static_deploy' do
    begin
      LOG.info("##### Static Deploy Request #####")
      request.body.rewind
      options = JSON.parse(request.env["rack.input"].read)
      config = Update::Options.new(options).config
      Update::Node.new(config)
    rescue Exception => 
      LOG.error(e.message)
      LOG.error(e.backtrace)
      abort
    end
  end

  post '/deploy' do
    begin
      LOG.info("##### Deploy Request Made #####")
      request.body.rewind
      options = JSON.parse(request.env["rack.input"].read) 
      config = Update::Options.new(options).config
      Update::Version.new(config)
      Update::Git.new(config)
      Update::Sleep.new(1)
      Update::Node.new(config)
    rescue Exception => e
      LOG.error(e.message)
      abort
    end
  end
	
  not_found do
		halt 404, 'Not found.'
	end
end

Rack::Handler::WEBrick.run(Server, opts) do |server|
	[:INT, :TERM].each { |sig| trap(sig) { server.stop } }
end

