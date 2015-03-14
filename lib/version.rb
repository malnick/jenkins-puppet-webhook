module Update
    class Version
        
        def initialize(config)
          LOG.info("##### Version Update In Progress #####")
          write(config)
        end

        def write(config)
            
          environment    = config[:environment]   # qa or production etc
          version        = config[:version]       # The version to write to the data file
          service        = config[:service]       # The service name
          data_file      = config[:data_file]
          key            = config[:key]

          abort "Cowardly refusing to update any nil values." if environment.nil? || version.nil? || service.nil?
 
          if File.exists? data_file
            LOG.info "Data file found #{data_file}, backing up to #{data_file}.backup"
            FileUtils.cp data_file, "#{data_file}.backup"
          else  
            abort LOG.error "#{data_file} is missing."
          end

          begin
            # Some basic checks for integrity
            LOG.info("Writing version number #{version} for service #{service} to #{data_file}")
            data = YAML.load(File.open(data_file, 'r')) 
            
            if data[key] == version
              exit LOG.info "Versions match, not doing anything."
            end
            unless data[key]
              exit LOG.error "Data key missing"
            end
            File.open(data_file, 'w') do |f|
              LOG.info("Updating version from #{data[key]} to #{version}")
              data[key] = version
              f.write(YAML.dump(data))
            end
          rescue Exception => e
            LOG.error('Exception found, moving backup data file to original')
            FileUtils.cp "#{data_file}.backup", data_file
            LOG.error(e.message)
          end

        end
    end
end

