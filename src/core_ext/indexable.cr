module Indexable(T)
  def sample(random = Random::DEFAULT, & : -> U) : T | U forall U
    case size
    when 0
      return yield
    when 1
      # Faster (x1.46) especially with Random::Secure (x301.56) on indexables
      # with only 1 element with a negligible penalty for the rest.
      return unsafe_fetch(0)
    end

    unsafe_fetch(random.rand(size))
  end

  def sample(random = Random::DEFAULT) : T
    sample(random) { raise IndexError.new }
  end

  def sample?(random = Random::DEFAULT) : T?
    sample(random) { nil }
  end

  def to_slice : Slice(T)
    Slice(T).new(size) { |i| unsafe_fetch(i) }
  end

  def bincludes?(val) : Bool
    bsearch { |n| n >= val } == val
  end

  def bsearch_index_of(obj : T) : Int32?
    if ret = bsearch_index { |value| value >= obj }
      if obj == unsafe_fetch(ret)
        ret
      end
    end
  end

  def local_each : Iterator(T)
    LocalItemIterator(self, T).new(self)
  end

  private struct LocalItemIterator(A, T)
    include Iterator(T)

    def initialize(@array : A, @index = 0)
    end

    def next
      if @index >= @array.size
        stop
      else
        value = @array[@index]
        @index &+= 1
        value
      end
    end
  end
end
