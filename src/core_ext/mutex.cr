class Mutex
  def owned? : Bool
    @mutex_fiber == Fiber.current
  end

  def locked? : Bool
    !!@mutex_fiber
  end

  def lock? : Bool
    if locked?
      return false
    end

    lock

    true
  end
end
