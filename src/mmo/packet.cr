abstract class MMO::Packet(T)
  property! buffer : ByteBuffer?
  property! client : T?

  def to_s(io : IO)
    io << {{@type.stringify}}
  end
end
