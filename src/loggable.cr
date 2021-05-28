module Loggable
  {% for name in %w(debug info warn error) %}
    def {{name.id}}(msg)
      Logs.{{name.id}}(self, msg)
    end

    def {{name.id}}(& : ->)
      Logs.{{name.id}}(self) { yield }
    end
  {% end %}
end
