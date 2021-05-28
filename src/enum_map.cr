# Hash-like type optimized for Enum and EnumClass keys.
class EnumMap(K, V)
  include Enumerable({K, V})

  private class NoValue
    INSTANCE = new
  end

  def initialize
    # Depending on require order, an EnumMap could be created before the enum's
    # members are created.
    unless K.size > 0
      raise "#{K} size cannot be 0"
    end
    @data = Pointer(V | NoValue).null
  end

  def each(&block : {K, V} ->) : Nil
    return unless @data
    K.size.times do |i|
      k = K[i]
      v = @data[k.to_i]
      unless v.is_a?(NoValue)
        yield({k, v})
      end
    end
  end

  def each_value(& : V ->)
    each { |k, v| yield v }
  end

  def each_key(& : K ->)
    K.size.times { |i| yield K[i] }
  end

  def []=(k : K, v : V)
    @data ||= Pointer(V | NoValue).malloc(K.size, NoValue::INSTANCE)
    @data[k.to_i] = v
  end

  def fetch(k : K)
    return yield unless @data
    val = @data[k.to_i]
    val.is_a?(NoValue) ? yield : val
  end

  def fetch(k : K, default)
    fetch(k) { default }
  end

  def [](k : K) : V
    fetch(k) { raise KeyError.new("Missing EnumMap key: #{k.inspect}") }
  end

  def []?(k : K) : V?
    fetch(k, nil)
  end

  def size : Int32
    size = 0
    each_key { size &+= 1 }
    size
  end

  def delete(k : K) : V?
    return yield unless @data
    val = @data[k.to_i]
    @data[k.to_i] = NoValue::INSTANCE
    val.is_a?(NoValue) ? yield : val
  end

  def delete(k : K)
    delete(k) { nil }
  end

  def delete_if
    each { |k, v| delete(k) if yield k, v }
  end

  def empty? : Bool
    return true unless @data
    each { return false }
    true
  end

  def keys : Array(K)
    keys = [] of K
    each_key { |k| keys << k }
    keys
  end

  def values : Array(V)
    values = [] of V
    each_value { |v| values << v }
    values
  end

  def values_at(*keys : K)
    keys.map { |k| self[k] }
  end

  def key_index(key)
    each_with_index { |(my_key, _), i| return i if key == my_key }
    nil
  end

  def merge(other : Hash(L, W) | self) forall L, W
    hash = EnumMap(K | L, V | W).new
    hash.merge!(self)
    hash.merge!(other)
    hash
  end

  def merge(other : Hash(L, W) | self, &block : K, V, W -> V | W) forall L, W
    hash = EnumMap(K | L, V | W).new
    hash.merge!(self)
    hash.merge!(other) { |k, v1, v2| yield k, v1, v2 }
    hash
  end

  def merge!(other : Hash)
    other.each { |k, v| self[k] = v }
    self
  end

  def merge!(other : self)
    return self unless other.@data
    @data ||= Pointer(V | NoValue).malloc(K.size, NoValue::INSTANCE)
    @data.copy_from(other.@data, K.size)
    self
  end

  def merge!(other : Hash | self, &block)
    other.each do |k, v|
      if self.has_key?(k)
        self[k] = yield k, self[k], v
      else
        self[k] = v
      end
    end
    self
  end

  def select(&block : K, V -> _)
    reject { |k, v| !yield(k, v) }
  end

  def select!(&block : K, V -> _)
    reject! { |k, v| !yield(k, v) }
  end

  def reject(&block : K, V -> _)
    each_with_object(EnumMap(K, V).new) do |(k, v), memo|
      memo[k] = v unless yield k, v
    end
  end

  def reject!(&block : K, V -> _)
    ret = nil
    each do |key, value|
      if yield key, value
        delete(key)
        ret = self
      end
    end
    ret
  end

  def reject(*keys)
    map = dup
    map.reject!(*keys)
  end

  def reject!(keys : Enumerable)
    keys.each { |k| delete(k) }
    self
  end

  def reject!(*keys)
    reject!(keys)
  end

  def select(keys : Enumerable | Tuple)
    hash = EnumMap(K, V).new
    keys.each { |k| hash[k] = self[k] if has_key?(k) }
    hash
  end

  def select(*keys)
    self.select(keys)
  end

  def select!(keys : Enumerable)
    each { |k, v| delete(k) unless keys.includes?(k) }
    self
  end

  def select!(*keys)
    select!(keys)
  end

  def compact
    ret = EnumMap(K, typeof(self[K[0]])).new
    each_with_object(ret) do |(key, value), memo|
      memo[key] = value unless value.nil?
    end
  end

  def clear : self
    @data = Pointer(V | NoValue).null
    self
  end

  def transform_keys(&block : K -> K2) forall K2
    each_with_object({} of K2 => V) do |(key, value), memo|
      memo[yield(key)] = value
    end
  end

  def transform_values(&block : V -> V2) forall V2
    each_with_object(EnumMap(K, V2).new) do |(key, value), memo|
      memo[key] = yield value
    end
  end

  def transform_values!(&block : V -> V)
    each { |k, v| self[k] = yield v }
  end

  def ==(other : self)
    return false if empty? && !other.empty?
    return false if !empty? && other.empty?
    empty? || LibC.memcmp(@data, other.@data, K.size) == 0
  end

  def self.zip(ary1 : Enumerable(K), ary2 : Enumerable(V))
    hash = EnumMap(K, V).new
    ary1.each_with_index { |key, i| hash[key] = ary2[i] }
    hash
  end

  def has_value?(val)
    each_value { |value| return true if value == val }
    false
  end

  def has_key?(key) : Bool
    return false unless key.is_a?(K) && @data
    !@data[key.to_i].is_a?(NoValue)
  end

  def dig?(key : K, *subkeys)
    if (value = self[key]?) && value.responds_to?(:dig?)
      value.dig?(*subkeys)
    end
  end

  def dig?(key : K)
    self[key]?
  end

  def dig(key : K, *subkeys)
    if (value = self[key]) && value.responds_to?(:dig)
      return value.dig(*subkeys)
    end

    raise KeyError.new("EnumMap value not diggable for key: #{key.inspect}")
  end

  def key_for(value)
    key_for(value) { raise KeyError.new("Missing EnumMap key for value: #{value}") }
  end

  def key_for?(value)
    key_for(value) { nil }
  end

  def key_for(value)
    each { |k, v| return k if v == value }
    yield value
  end

  def store_if_absent(key : K, value : V) : V
    store_if_absent(key) { value }
  end

  def store_if_absent(key : K, & : -> V) : V
    has_key?(key) ? self[key] : (self[key] = yield)
  end

  def hash(hasher)
    result = hasher.result

    each do |key, value|
      copy = hasher
      copy = key.hash(copy)
      copy = value.hash(copy)
      result += copy.result
    end

    result.hash(hasher)
  end

  def dup : self
    map = EnumMap(K, V).new
    each { |k, v| map[k] = v }
    map
  end

  def clone : self
    map = EnumMap(K, V).new
    each { |k, v| map[k] = v.clone }
    map
  end

  def to_h : Hash(K, V)
    h = {} of K => V
    each { |k, v| h[k] = v }
    h
  end

  def to_s(io : IO)
    io.print("EnumMap(", K, ", ", V, ") {")
    each_with_index do |(key, value), index|
      io << ", " if index != 0
      io.print(key, " => ", value)
    end
    io << "}"
  end

  def inspect(io : IO)
    io.print("EnumMap(", K, ", ", V, ") {")
    each_with_index do |(key, value), index|
      io << ", " if index != 0
      key.inspect(io)
      io << " => "
      value.inspect(io)
    end
    io << "}"
  end
end
