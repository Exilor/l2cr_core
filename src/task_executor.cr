require "./priority_queue"
require "./worker_pool"

class TaskExecutor
  def initialize(*, pool_size = 20, error_handler = ->raise(Exception))
    @pool = WorkerPool.new(pool_size, error_handler)
  end

  def execute(task)
    @pool.enqueue(task)
  end

  def shutdown
    @pool.shutdown
  end
end
