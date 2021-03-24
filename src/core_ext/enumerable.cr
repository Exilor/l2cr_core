module Enumerable(T)
  def safe_each(& : T ->)
    each { |e| yield e }
  end

  def flat_each
    each do |e|
      if e.responds_to?(:flat_each)
        e.flat_each { |e2| yield e2 }
      else
        yield e
      end
    end
  end
end
