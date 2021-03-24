class StatsSet < Hash(String, String)
  def merge!(arg)
    arg.each { |k, v| self[k] = v }
  end

  def []=(key : String, value)
    super(key, value.to_s) unless value.nil?
  end

  {% for name in %w(i8 i16 i32 i64 u8 u16 u32 u64 f32 f64) %}
    {% prefix = name.starts_with?('i') ? "Int".id : (name.starts_with?('u') ? "UInt".id : "Float".id) %}
    {% type = "#{prefix}#{name[1..-1].id}".id %}

    def get_{{name.id}}(key : String) : {{type}}
      self[key].to_{{name.id}}(strict: false)
    end

    def get_{{name.id}}(key : String, default) : {{type}}
      fetch(key) { return default.to_{{name.id}} }.to_{{name.id}}(strict: false)
    end
  {% end %}

  def get_bool(key : String) : Bool
    self[key].to_b
  end

  def get_bool(key : String, default)
    fetch(key) { return default }.to_b
  end

  def get_string(key : String) : String
    self[key]
  end

  def get_string(key : String, default)
    fetch(key, default)
  end

  def get_regex(key : String) : Regex
    /#{get_string(key)}/
  end

  def get_regex(key : String, default)
    /#{get_string(key, default)}/
  end

  def get_enum(key : String, enum_class)
    enum_class.parse(get_string(key))
  end

  def get_enum(key : String, enum_class, default)
    enum_class.parse(fetch(key) { return default })
  end

  EMPTY = new
end
