module Update
  class Options
    
    attr_accessor :config

    def initialize(options)
      options = {} if options.nil?
          
      LOG.info("##### Parsing Options #####")
  
      @config         = Hash.new

      # Required data from POST - if any of these are nil they'll actually break shit - leaving nil so we can use them in the get request
      @config[:environment]    = options['environment']     || nil # qa or production etc
      @config[:version]        = options['version']         || nil # The version to write to the data file
      @config[:service]        = options['service']         || nil # The service name
      @config[:role]           = options['role']            || nil # The role for the nodes to update via mCollective
      
      # Optional data from POST
      @config[:key]            = options['key']             || "#{@config[:service]}_version_#{@config[:environment]}"   
      @config[:git_repo]       = options['git_repo']        || 'git@github.com:sourceclear/puppet-control.git'
      @config[:git_repo_dir]   = options['git_repo_dir']    || '/etc/puppetlabs/puppet/environments/production'
      @config[:data_file]      = options['data_file_path']  || "#{@config[:git_repo_dir]}/hieradata/versions.yaml"
      
      LOG.info("##### Setting configuration #####")
      @config.each do |k,v|
        LOG.info("#{k}: #{v}")
      end
    end
  end
end
