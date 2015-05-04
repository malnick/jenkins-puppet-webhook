module Update
  class Sleep
    def initialize(time)
      Log.info("##### Sleep Cycle with S3 Updates #####")
      time.times do |n|
        Log.info("Running on MCO in #{time - n} seconds")   
        n = n - 1
      end
    end
  end
end
