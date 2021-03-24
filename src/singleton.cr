module Singleton
  macro included
    def self.instance : self
      @@instance ||= new
    end

    macro method_added(m)
      \{% if m.name == "initialize" %}
        private def initialize
          previous_def
        end
      \{% end %}
    end
  end
end
