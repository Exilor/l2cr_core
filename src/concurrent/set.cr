require "./synchronized_object"

module Concurrent
  struct Set(T) < SynchronizedObject
    def initialize(initial_capacity : Int = 1)
      @set = ::Set(T).new(initial_capacity)
    end

    delegate to_s, inspect, to: @set
    sync_delegate empty?, delete, add, add?, clear, concat, subtract, :<<,
      to: @set

    {% for m in Enumerable.methods %}
      sync_delegate "{{m.name}}", to: @set
    {% end %}

    def each
      sync { @set.each { |e| yield e } }
    end

    def select
      sync { @set.select { |e| yield e } }
    end
  end
end
