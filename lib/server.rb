require 'rubygems'
require 'rack'
require 'sinatra'
require 'webrick'
require 'logger'
require 'json'
require File.expand_path(File.dirname(__FILE__)) + '/update'

# Get configuration for ci_webhook
#Update::Setup.new

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
      Update::Git.new(config)
    rescue Exception => e
      LOG.error(e.message)
      abort
    end
  end
	
  get '/status' do
    begin
      LOG.info('##### Request for Status Made #####')
      # Get the local hiera versions on the Puppet Master 
      get_versions_in_hiera_local
      # Get the versions from the $::service_version fact POSTed to the Puppet Master /status
      #get_versions_on_nodes
      json_y_fy
      erb :index
    rescue Exception => e
      LOG.error(e.message)
      abort
    end
  end

  not_found do
		halt 404, 'Not found.'
	end

  post '/status' do
    LOG.info("##### Invoked Post to /status #####")
    request.body.rewind
    new_data = JSON.parse(request.env["rack.input"].read)
    File.open("/var/node_data/#{new_data['hostname']}.json", "w") do |f|
      LOG.info("Posting new data: #{new_data}")
      f.write(new_data.to_json)
    end
    "Response Received by Puppet Master"
  end
  
  def json_y_fy
    @local_hiera_versions = @local_hiera_versions.to_json
  end

  def get_versions_in_hiera_local
    @local_hiera_versions = {}
    begin
      LOG.info("##### Getting Current Versions on Node #####")
      config = Update::Options.new({}).config
      YAML.load(File.open(config[:data_file])).each do |k,v|
        @local_hiera_versions[k] = v
      end
      LOG.info("##### Current Versions: #####") 
      @local_hiera_versions.each do |k,v|
        LOG.info("#{k}: #{v}")
      end
    rescue Exception => e
      LOG.error(e.message)
      abort
    end
    @local_hiera_versions
  end

end

Rack::Handler::WEBrick.run(Server, opts) do |server|
	[:INT, :TERM].each { |sig| trap(sig) { server.stop } }
end

