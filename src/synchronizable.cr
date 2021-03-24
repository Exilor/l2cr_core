module Synchronizable
  macro included
    @synchronizable_lock = Mutex.new(:Reentrant)

    def sync
      @synchronizable_lock.synchronize { yield }
    end
  end

  macro extended
    private SYNCHRONIZABLE_LOCK = Mutex.new(:Reentrant)

    def self.sync
      SYNCHRONIZABLE_LOCK.synchronize { yield }
    end
  end
end
