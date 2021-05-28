# Set-like type optimized for Enum and EnumClass.
class EnumSet(T)
  include Enumerable(T)

  property mask : UInt64
  def_equals_and_hash @mask

  def initialize(set : Bool = false)
    if T.size > 64
      raise "#{T}'s mask wouldn't fit an UInt64"
    elsif T.size == 0
      raise "Size of #{T} must be greater than 0"
    end

    @mask = set ? T.mask : 0u64
  end

  def initialize(mask : Int)
    @mask = mask.to_u64
  end

  def initialize(args : Enumerable(T))
    unless T.size > 0
      raise "Size of #{T} must be greater than 0"
    end
    @mask = 0u64
    args.each { |a| self << a }
  end

  def each : Nil
    T.each { |m| yield m if includes?(m) }
  end

  def set_all : self
    @mask = T.mask
    self
  end

  def clear : self
    @mask = 0u64
    self
  end

  def <<(m : T) : self
    @mask |= m.mask
    self
  end

  def delete(m : T) : self
    @mask &= ~m.mask
    self
  end

  def includes?(m : T) : Bool
    @mask & m.mask != 0
  end

  def ===(other : self) : Bool
    includes?(other)
  end

  def -(other : self) : self
    EnumSet(T).new(@mask & ~other.@mask)
  end

  def ^(other : self) : self
    EnumSet(T).new(@mask ^ other.@mask)
  end

  def |(other : self) : self
    EnumSet(T).new(@mask | other.@mask)
  end

  def &(other : self) : self
    EnumSet(T).new(@mask & other.@mask)
  end

  def subtract(other) : self
    other.each { |m| delete(m) }
    self
  end

  def dup : self
    EnumSet(T).new(@mask)
  end

  def concat(other : Enumerable(T)) : self
    other.each { |m| self << m }
    self
  end

  def clone : self
    EnumSet(T).new(@mask)
  end

  def mask=(mask : Int)
    @mask = mask.to_u64
  end
end
