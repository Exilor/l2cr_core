class Mutex
  def owned?
    @mutex_fiber == Fiber.current
  end

  def locked?
    !!@mutex_fiber
  end

  def lock?
    if locked?
      return false
    end

    lock

    true
  end
end
