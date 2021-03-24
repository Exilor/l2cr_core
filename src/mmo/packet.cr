abstract class MMO::Packet(T)
  property! buffer : ByteBuffer?
  property! client : T?

  def to_s(io : IO)
    self.class.to_s(io)
  end
end
