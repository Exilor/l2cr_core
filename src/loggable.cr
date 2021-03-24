module Loggable
  {% for name in %w(debug info warn error) %}
    macro {{name.id}}(msg = nil, &block)
      if Logs.debug?
        \{% if block %}
          Logs.{{name.id}}(self, \{{block.body}})
        \{% else %}
          Logs.{{name.id}}(self, \{{msg}})
        \{% end %}
      end
    end
  {% end %}
end
