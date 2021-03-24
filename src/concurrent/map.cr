require "./synchronized_object"

module Concurrent
  struct Map(K, V) < SynchronizedObject
    include Enumerable({K, V})

    @hash = {} of K => V

    delegate to_s, inspect, to: @hash

    def each(& : {K, V} ->)
      sync { @hash.each { |k, v| yield({k, v}) } }
    end

    def merge(other : self)
      sync { other.sync { @hash.merge(other.@hash) } }
    end

    def select!(& : K, V ->)
      sync { @hash.select! { |k, v| yield k, v } }
      self
    end

    def select_values(& : V ->) : ::Array(V)
      sync do
        ret = [] of V
        @hash.each_value { |v| ret << v if yield v }
        ret
      end
    end

    def transform_values!
      sync { @hash.transform_values! { |v| yield v } }
      self
    end

    def [](key)
      sync { @hash[key] }
    end

    def []?(key)
      sync { @hash[key]? }
    end

    def []=(k, v)
      sync { @hash[k] = v }
    end

    def empty?
      sync { @hash.empty? }
    end

    def has_key?(k)
      sync { @hash.has_key?(k) }
    end

    def fetch(k)
      sync { @hash.fetch(k) }
    end

    def fetch(k, default)
      sync { @hash.fetch(k, default) }
    end

    def fetch(k)
      sync { @hash.fetch(k) { yield } }
    end

    def delete(k)
      sync { @hash.delete(k) }
    end

    def each_value
      # stack overflow
      # sync { @hash.each_value { |v| yield v } }
      sync { @hash.local_each_value.each { |v| yield v } }
    end

    def each_key
      sync { @hash.each_key { |k| yield k } }
    end

    def local_each_value
      sync { @hash.local_each_value }
    end

    def values
      sync { @hash.values }
    end

    def keys
      sync { @hash.keys }
    end

    def values_slice
      sync { @hash.values_slice }
    end

    def clear
      sync { @hash.clear }
      self
    end

    def find_value
      sync { @hash.find_value { |v| yield v } }
    end

    def dig(key, *subkeys)
      sync { @hash.dig(key, *subkeys) }
    end

    def dig?(key, *subkeys)
      sync { @hash.dig?(key, *subkeys) }
    end
  end
end
