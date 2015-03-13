module Update
  class Node
    def initialize(options)
      LOG.info("Executing run on all nodes matching the #{options['role']} role")
      role = options['role']
      update_node(role)
    end

    def update_node(role)
      IO.popen("su - peadmin -c 'mco puppet runonce -F role=#{role}'") do |output|
        output.each do |line| LOG.info(line.strip.chomp) end
      end 
    end
  end
end
    
