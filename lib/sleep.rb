module Update
  class Sleep
    def initialize(time)
      LOG.info("##### Sleep Cycle with S3 Updates #####")
      time.times do |n|
        LOG.info("Running on MCO in #{time - n} seconds")   
        n = n - 1
      end
    end
  end
end
