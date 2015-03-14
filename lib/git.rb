module Update
  class Git
    def initialize(config)
      
      LOG.info("##### Updating Git #####")
      git_repo_dir  = config[:git_repo_dir]
      
      test_locality(git_repo_dir)
      push_git(git_repo_dir)
  
    end
      
      def test_locality(git_repo_dir)
        
        LOG.info("Checking #{git_repo_dir} to ensure it's usable") 
        unless Dir.exists? git_repo_dir
          abort LOG.error("#{git_repo_dir} does not exist.")
        end
        
        begin
          g = Git.init(git_repo_dir)
          g.index.readable?
          g.index.writable?
        rescue Exception => e 
          abort LOG.error(e.message)
        end
      
      end

      def push_git(git_repo_dir)
        LOG.info("Pushing updated code to git")
        g = Git.init(git_repo_dir, :log => LOG)
      end
  end
end