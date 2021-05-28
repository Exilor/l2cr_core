class Deque(T)
  def delete_first(elem : T) : T?
    if idx = index(elem)
      delete_at(idx)
    end
  end

  def delete_last(elem : T) : T?
    if idx = rindex(elem)
      delete_at(idx)
    end
  end

  def safe_each(& : T ->)
    reverse_each { |e| yield e }
  end
end
