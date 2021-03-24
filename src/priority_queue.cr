struct PriorityQueue(T)
  @values = [] of T

  def peek : T?
    @values.last?
  end

  def get : T?
    @values.pop?
  end

  def add(val : T) : Nil
    index = bisect_right(val)
    @values.insert(index, val)
  end

  private def bisect_right(val)
    l = 0
    u = @values.size
    while l < u
      m = l &+ ((u &- l) // 2)

      if @values.unsafe_fetch(m) >= val
        l = m &+ 1
      else
        u = m
      end
    end

    l
  end
end
