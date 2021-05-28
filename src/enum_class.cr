# Java-style enum type (allowing instance variables) with Crystal's Enum
# interface.
# Example:
# class Color < EnumClass
#   def initialize(@hex : String)
#   end
#
#   add(RED, "0xFF0000")
#   add(GREEN, "0x00FF00")
#   add(BLUE, "0x0000FF")
# end
abstract class EnumClass
  macro inherited
    extend Indexable(self)
    include Comparable(self)

    private ENUM_MEMBERS = [] of self

    getter to_i = -1
    getter to_s = ""
    protected setter to_i, to_s

    def_equals_and_hash @to_i

    {% for name in %w(i8 i16 i32 i64 u8 u16 u32 u64 f32 f64) %}
      {% prefix = name.starts_with?('i') ? "Int".id : (name.starts_with?('u') ? "UInt".id : "Float".id) %}
      {% type = "#{prefix}#{name[1..-1].id}".id %}

      def to_{{name.id}} : {{type}}
        @to_i.to_{{name.id}}!
      end
    {% end %}

    def to_f : Float64
      @to_i.to_f64
    end

    def <=>(other : self) : Int32
      @to_i <=> other.@to_i
    end

    def mask : UInt64
      1u64 << @to_i
    end

    def dup : self
      self
    end

    def clone : self
      self
    end

    def to_s(io : IO) : Nil
      io << @to_s
    end

    def inspect(io : IO) : Nil
      io.print({{@type.stringify + "::"}}, @to_s)
    end

    def self.mask : UInt64
      (1u64 << size) &- 1
    end

    def self.size : Int32
      ENUM_MEMBERS.size
    end

    def self.unsafe_fetch(index : Int) : self
      ENUM_MEMBERS.unsafe_fetch(index)
    end

    def self.parse?(name : String) : self?
      find { |m| m.@to_s.casecmp?(name) }
    end

    def self.parse(name : String) : self
      parse?(name) ||
        raise ArgumentError.new("Unknown #{self} with name \"#{name}\"")
    end
  end

  private macro add(name, *args, **opts, &block)
    {{name.id}} = allocate
    {{name.id}}.to_i = ENUM_MEMBERS.size
    {{name.id}}.to_s = {{name.stringify}}

    ENUM_MEMBERS << {{name.id}}

    def {{name.stringify.underscore.id}}? : Bool
      same?({{name.id}})
    end

    {% if !args.empty? && !opts.empty? %}
      {{name.id}}.initialize({{*args}}, {{**opts}}) {{ block }}
    {% elsif !args.empty? %}
      {{name.id}}.initialize({{*args}}) {{ block }}
    {% else %}
      {{name.id}}.initialize({{**opts}}) {{ block }}
    {% end %}
  end
end
