require "./synchronized_object"

module Concurrent
  struct Array(T) < SynchronizedObject
    @array = [] of T

    def initialize(@array : ::Array(T))
    end

    def initialize(*args)
      @array = ::Array(T).new(*args)
    end

    delegate to_s, inspect, to: @array
    sync_delegate :[], :[]?, :[]=, empty?, find, clear, :<<, delete_at, push,
      delete_first, reject!, replace, concat, shift, shift?, pop, delete, sum,
      includes?, count, any?, sample?, each_with_index, to_slice, flat_each,
      all?, to: @array

    {% for m in Indexable.methods %}
      sync_delegate "{{m.name}}", to: @array
    {% end %}

    def each
      # stack overflow
      # sync { @array.each { |e| yield e } }
      sync { @array.local_each.each { |e| yield e } }
    end

    def safe_each
      sync { @array.safe_each { |e| yield e } }
    end

    def reject
      sync { @array.reject { |e| yield e } }
    end

    def select
      sync { @array.select { |e| yield e } }
    end

    def max_of
      sync { @array.max_of { |e| yield e } }
    end

    def map
      sync { @array.map { |e| yield e } }
    end
  end
end
