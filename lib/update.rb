require 'json'
require 'yaml'
require 'fileutils'

module Update
    class Version
        
        def initialize(options)
          write(options)
        end


        def write(options)
          
          # UPDATE THIS PATH !!  
          data_file      = File.expand_path(File.dirname(__FILE__)) + '/../ext/global.yaml'
          # ...AND MAYBE THIS KEY !!
          key            = "#{service}_version_#{environment}"
          
          environment    = options['environment']   # qa or production etc
          version        = options['version']       # The version to write to the data file
          service        = options['service']       # The service name

          abort "Cowardly refusing to update any nil values." if environment.nil? || version.nil? || service.nil?
 
          if File.exists? data_file
            
            LOG.info "Data file found #{data_file}, backing up to #{data_file}.backup"
            FileUtils.cp data_file, "#{data_file}.backup"

          else  

            abort LOG.error "#{data_file} is missing."

          end

          begin
            
            LOG.info("Writing version number #{version} for service #{service} to #{data_file}")
        
            data = YAML.load(File.open(data_file, 'r')) 

            if data[key] == version

              abort LOG.error "Versions match, not doing anything."
            
            end
           
            unless data[key]
              
              abort LOG.error "Data key missing"

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
            LOG.error(e.backtrace) 

          end

        end
    end
end

