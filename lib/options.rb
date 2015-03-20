module Update
  class Options
    
    attr_accessor :config

    def initialize(options)
    
      LOG.info("##### Parsing Options #####")
  
      @config         = Hash.new

      # Required data from POST
      @config[:environment]    = options['environment']   # qa or production etc
      @config[:version]        = options['version']       # The version to write to the data file
      @config[:service]        = options['service']       # The service name
      @config[:role]           = options['role']          # The role for the nodes to update via mCollective
      
      # Optional data from POST
      @config[:key]            = options['key']             || "#{@config[:service]}_version_#{@config[:environment]}"   
      @config[:git_repo]       = options['git_repo']        || 'git@github.com:malnick/puppet-control'
      @config[:git_repo_dir]   = options['git_repo_dir']    || '/etc/puppetlabs/puppet/environments/production/hieradata'
      @config[:data_file]      = options['data_file_path']  || "#{@config[:git_repo_dir]}/global.yaml"
      
      LOG.info("##### Setting configuration #####")
      @config.each do |k,v|
        LOG.info("#{k}: #{v}")
      end
    end
  end
end
