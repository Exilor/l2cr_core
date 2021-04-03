# Allows reading from a DB::ResultSet using column names (as strings or symbols)
# instead of sequentially.
struct ResultSetReader
  private alias KeyType = String | Symbol
  private alias ValueType = String | Bool | Time | Bytes | Number::Primitive?

  private record Entry, column_name : String, value : ValueType

  def initialize(rs)
    @data = Slice(Entry).new(rs.column_count) do |i|
      Entry.new(rs.column_name(i), rs.read(ValueType))
    end
  end

  {% for name in %w(i8 i16 i32 i64 u8 u16 u32 u64 f32 f64) %}
    {% prefix = name.starts_with?('i') ? "Int".id : (name.starts_with?('u') ? "UInt".id : "Float".id) %}
    {% type = "#{prefix}#{name[1..-1].id}".id %}

    def get_{{name.id}}(key : KeyType) : {{type}}
      case value = get(key)
      when .nil?
        0{{name.id}}
      when String
        value.to_{{name.id}}
      else
        value.as(Number::Primitive).to_{{name.id}}!
      end
    end
  {% end %}

  def get_string(key : KeyType) : String
    get(key).as(String)
  end

  def get_string?(key : KeyType) : String?
    get(key).as(String?)
  end

  def get_time(key : KeyType) : Time
    get(key).as(Time)
  end

  def get_bytes(key : KeyType) : Bytes
    case value = get(key)
    when .nil?
      Bytes.empty
    when Bytes
      value
    when String
      value.to_slice
    else
      raise "Invalid value for Bytes: '#{value}'"
    end
  end

  def get_bool(key : KeyType) : Bool
    case value = get(key)
    when Bool
      value
    when Int
      value == 1
    when String
      value.to_b
    else
      raise "Invalid value for Bool: '#{value}'"
    end
  end

  private def get(key : Symbol) : ValueType
    get(key.to_s)
  end

  private def get(key : String) : ValueType
    if entry = @data.find &.column_name.casecmp?(key)
      return entry.value
    end

    raise KeyError.new("Column '#{key}' was not selected")
  end
end
