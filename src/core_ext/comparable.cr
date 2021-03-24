module Comparable(T)
  def between?(min : T, max : T) : Bool
    min <= self <= max
  end
end
