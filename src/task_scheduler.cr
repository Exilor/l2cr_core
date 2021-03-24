require "./task_executor"

class TaskScheduler < TaskExecutor
  @scheduling_worker : Fiber

  def initialize(*, pool_size = 20, error_handler = ->raise(Exception))
    # Implicit args super throws a syntax error due to a compiler bug
    super(pool_size: pool_size, error_handler: error_handler)

    @queue = PriorityQueue(Task).new
    @queue_lock = Mutex.new
    @scheduling_worker = init_scheduler
  end

  def schedule_delayed(callable, delay)
    DelayedTask.new(self, callable, delay)
  end

  def schedule_periodic(callable, delay, interval)
    PeriodicTask.new(self, callable, delay, interval)
  end

  private def init_scheduler
    spawn do
      loop do
        delay = nil

        @queue_lock.synchronize do
          ms = nil
          while (task = @queue.peek) && (ms ||= Time.local.to_unix_ms) >= task.@execute_at
            @queue.get
            task.fire
          end
          delay = task.try &.delay
          ms = nil
        end

        if delay && delay >= 0
          sleep(delay.milliseconds)
        else
          sleep
        end
      end
    end
  end

  protected def schedule(task)
    @queue_lock.synchronize { @queue.add(task) }
    @scheduling_worker.resume_event.add(0.seconds)
  end

  abstract class Task
    include Comparable(self)

    @callable : (->)?

    def initialize(scheduler : TaskScheduler, callable : Proc(_), delay)
      @scheduler = scheduler
      @callable = callable.unsafe_as(Proc(Nil))
      @execute_at = Int64.new(Time.local.to_unix_ms + delay)
      scheduler.schedule(self)
    end

    def initialize(scheduler : TaskScheduler, callable, delay)
      @scheduler = scheduler
      @callable = -> { callable.call; nil }
      @execute_at = Int64.new(Time.local.to_unix_ms + delay)
      scheduler.schedule(self)
    end

    protected def fire
      @scheduler.try &.execute(self)
    end

    def call
      @callable.try &.call
    end

    def delay
      @execute_at - Time.local.to_unix_ms
    end

    def cancel
      @scheduler = nil
    end

    def cancelled?
      @scheduler.nil?
    end

    def done?
      @callable.nil? || @scheduler.nil?
    end

    def <=>(other : self)
      @execute_at <=> other.@execute_at
    end
  end

  class DelayedTask < Task
    def call
      super
      @callable = nil
    end
  end

  class PeriodicTask < Task
    def initialize(scheduler, callable, delay, interval)
      @interval = Int32.new(interval)
      super(scheduler, callable, delay)
    end

    def call
      super
    ensure
      if sch = @scheduler
        @execute_at = Time.local.to_unix_ms + @interval
        sch.schedule(self)
      end
    end
  end
end
