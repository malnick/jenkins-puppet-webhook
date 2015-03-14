module Update
  class Options
    
    attr_accessor :config

    def initialize(options)
      
      @config         = Hash.new

      # Required data from POST
      @config[:environment]    = options['environment']   # qa or production etc
      @config[:version]        = options['version']       # The version to write to the data file
      @config[:service]        = options['service']       # The service name
      
      # Optional data from POST
      @config[:key]            = options['key']             || "#{@config[:service]}_version_#{@config[:environment]}"   
      @config[:git_repo_dir]   = options['git_repo_dir']    || '/tmp/control'
      @config[:data_file]      = options['data_file_path']  || "#{@config[:git_repo_dir]}/global.yaml"
      
      LOG.info("##### Setting configuration #####")
      @config.each do |k,v|
        LOG.info("#{k}: #{v}")
      end
      LOG.info("##### end #####")
    end
  end
end
