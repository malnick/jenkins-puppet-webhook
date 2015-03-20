module Update
  class Node
    def initialize(config)
      LOG.info("##### Updating Nodes #####")
      LOG.info("Executing run on all nodes matching the #{config[:role]} role")
      role = config[:role]
      update_node(role)
    end

    def update_node(role)
      if role.is_a? Array
        role.each do |i| 
          IO.popen("su - peadmin -c 'mco puppet runonce -F role=#{i}'") do |output|
            output.each do |line| LOG.info(line.strip.chomp) end
          end
        end
      else
        LOG.error("Role value must be an array.")
      end 
    end
  end
end
    
