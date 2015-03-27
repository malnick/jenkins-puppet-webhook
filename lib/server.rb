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

  helpers do
    
    def get_versions_on_node()
      begin
        LOG.info("##### Getting Current Versions on Node #####")
        config = Update::Options.new(options).config
        @current_versions = File.open(YAML.load(config(:data_file)))
        LOG.info("Set current versions to #{@current_versions}")
      rescue Exception => e
        LOG.error(e.message)
        abort
      end
    end

  end 

  post '/deploy' do
    begin
      LOG.info("##### Request to Server Made #####")
      request.body.rewind
      options = JSON.parse(request.env["rack.input"].read) 
      config = Update::Options.new(options).config
      Update::Version.new(config)
      Update::Node.new(config)
      Update::Git.new(config)
    rescue Exception => e
      LOG.error(e.message)
      abort
    end
  end
	
  get '/status' do
    begin
      LOG.info('##### Request for Status Made #####')
      get_versions_on_node
      erb :index
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

