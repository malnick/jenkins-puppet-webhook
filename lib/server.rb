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

  post '/deploy' do
    begin
      LOG.info("##### Request to Server Made #####")
      request.body.rewind
      options = JSON.parse(request.env["rack.input"].read) 
      config = Update::Options.new(options).config
      Update::Version.new(config)
      Update::Node.new(config)
# Not quite yet...
#      Update::Git.new(config)
    rescue Exception => e
      LOG.error(e)
      e.backtrace.each do |o|
        LOG.error(o)
      end
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

