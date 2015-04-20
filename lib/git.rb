module Update
  class Git 
    
    def initialize(config)
      
      LOG.info("##### Updating Git #####")
      git_repo_dir  = config[:git_repo_dir]
      test_locality(git_repo_dir)
      push_git(git_repo_dir,config)
  
    end
      
      def test_locality(git_repo_dir)
        
        LOG.info("Checking #{git_repo_dir} to ensure it's usable") 
        unless Dir.exists? git_repo_dir
          abort LOG.error("#{git_repo_dir} does not exist.")
        end
        
        begin
          g = ::Git.open(git_repo_dir)
          g.index.readable?
        rescue Exception => e 
          LOG.error("The git index does not appear to be readable.")
          LOG.error("Make sure the repo is an actual git repo.")
          abort LOG.error(e.message)
        end
      
      end

      def push_git(git_repo_dir,config)
        LOG.info("Pushing updated code to git")
        begin
          g = ::Git.open(git_repo_dir, :log => LOG)

          g.branch('temp').checkout
          # Add our datafile and backup
          g.add(config[:data_file])
          g.add("#{config[:data_file]}.backup")
          
          # Commit changes to current branch
          g.commit("WEBHOOK: Updating service #{config[:service]} to version #{config[:version]}")
 
          # Checkout production   
          g.branch('production')

          # Merge in the changes to production
          g.merge('temp')
          
          # Pull in changes from remote
          g.pull(g.remote('origin'), g.branch('production'))

          # Push to git
          g.push(g.remote('origin'), g.branch('production')) 

          # Remove temp branch
          g.branch('temp').delete

        rescue Exception => e
          LOG.error(e.message)
        end
      end
  end
end
