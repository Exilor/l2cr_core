require "../synchronizable"

module Concurrent
  private abstract struct SynchronizedObject
    include Synchronizable

    private macro sync_delegate(*methods, to object)
      {% for method in methods %}
        {% if method.id.ends_with?('=') && method.id != "[]=" %}
          def {{method.id}}(arg)
            sync { {{object.id}}.{{method.id}} arg }
          end
        {% else %}
          def {{method.id}}(*args, **options)
            sync { {{object.id}}.{{method.id}}(*args, **options) }
          end

          {% if method.id != "[]=" %}
            def {{method.id}}(*args, **options)
              sync do
                {{object.id}}.{{method.id}}(*args, **options) do |*yield_args|
                  yield *yield_args
                end
              end
            end
          {% end %}
        {% end %}
      {% end %}
    end
  end
end
