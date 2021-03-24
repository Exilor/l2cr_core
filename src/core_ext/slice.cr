struct Slice(T)
  def self.new(size : Int, *, read_only = false)
    {% unless T <= Int::Primitive || T <= Float::Primitive || T.union_types.includes?(Nil) %}
      {% raise "Can only use primitive integers, floats and nilable types with Slice.new(size), not #{T}" %}
    {% end %}

    pointer = Pointer(T).malloc(size)
    new(pointer, size, read_only: read_only)
  end

  def +(other : self) : self
    new_size = size + other.size
    ptr = Pointer(T).malloc(new_size)
    slice = Slice(T).new(ptr, new_size)
    copy_to(slice)
    other.copy_to(slice + other.size)
    slice
  end

  def add(*values : T) : self
    total_size = size + values.size
    ptr = Pointer(T).malloc(total_size)
    ptr.copy_from(to_unsafe, size)
    values.each_with_index { |val, i| ptr[size + i] = val }
    ptr.to_slice(total_size)
  end
end
