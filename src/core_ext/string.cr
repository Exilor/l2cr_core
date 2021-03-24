class String
  def casecmp?(other : String) : Bool
    compare(other, true) == 0
  end

  private record CaseInsensitiveComparator, string : String

  def ===(other : CaseInsensitiveComparator) : Bool
    casecmp?(other.string)
  end

  def casecmp : CaseInsensitiveComparator
    CaseInsensitiveComparator.new(self)
  end

  def starts_with?(*args : Object)
    args.any? { |a| starts_with?(a) }
  end

  def ends_with?(*args : Object)
    args.any? { |a| ends_with?(a) }
  end

  def from(pos : Int) : String
    self[pos..-1]
  end

  def to(pos : Int) : String
    self[0..pos]
  end

  def alnum? : Bool
    return false if empty?
    each_char { |c| return false unless c.alphanumeric? }
    true
  end

  def number? : Bool
    return false if empty?
    each_char { |c| return false unless c.number? }
    true
  end

  def to_b : Bool
    if casecmp?("true")
      true
    elsif casecmp?("false")
      false
    else
      raise ArgumentError.new("Invalid value for Bool: \"#{self}\"")
    end
  end
end
