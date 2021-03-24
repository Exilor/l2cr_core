class Deque(T)
  def delete_first(elem)
    if idx = index(elem)
      delete_at(idx)
    end
  end

  def delete_last(elem)
    if idx = rindex(elem)
      delete_at(idx)
    end
  end

  def safe_each : Nil
    reverse_each { |e| yield e }
  end
end
