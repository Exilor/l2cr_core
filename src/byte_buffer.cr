class ByteBuffer < IO::Memory
  def slice : Bytes
    @buffer.to_slice(@capacity)
  end

  def to_unsafe
    @buffer
  end

  def remaining : Int32
    @bytesize &- @pos
  end

  def remaining? : Bool
    remaining > 0
  end

  def compact
    temp = @bytesize &- @pos
    @buffer.move_from(@buffer + @pos, temp)
    @pos = 0
    @bytesize = temp
    self
  end

  def limit : Int32
    @bytesize
  end

  def limit=(lim : Int)
    @bytesize = lim.to_i32
  end

  def pos=(pos : Int)
    super

    if @bytesize < pos
      @bytesize = pos.to_i32
    end
  end

  private def check_writeable
    # no-op (always writeable)
  end

  private def check_resizeable
    # no-op (always resizeable)
  end

  protected def check_open
    # no-op (always open)
  end

  def closed? : Bool
    false
  end
end
