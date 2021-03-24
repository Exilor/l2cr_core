require "./unbounded_channel"

class WorkerPool
  def initialize(pool_size, error_handler : (Exception ->)?)
    @error_handler = error_handler
    @tasks = UnboundedChannel(->).new
    pool_size.times { new_worker }
  end

  def shutdown
    @tasks.close
  end

  def enqueue(task : ->)
    return if @tasks.closed?
    @tasks.send(task)
  end

  def enqueue(task)
    return if @tasks.closed?
    @tasks.send(-> { task.call })
  end

  private def new_worker
    spawn do
      while task = @tasks.receive?
        begin
          task.call
        rescue e
          @error_handler.try &.call(e)
        end
      end
    end
  end
end
