require "./synchronized_object"

module Concurrent
  struct Deque(T) < SynchronizedObject
    @deque = ::Deque(T).new

    delegate to_s, inspect, to: @deque
    sync_delegate :[], :[]?, :[]=, empty?, find, delete_first, :<<, shift,
      shift?, concat, clear, first, first?, delete, delete_if, any?, to: @deque

    {% for m in Indexable.methods %}
      sync_delegate "{{m.name}}", to: @deque
    {% end %}

    def each
      sync { @deque.each { |e| yield e } }
    end

    def safe_each
      sync { @deque.safe_each { |e| yield e } }
    end

    def unsafe_fetch(index : Int)
      sync { @deque.unsafe_fetch(index) }
    end
  end
end
