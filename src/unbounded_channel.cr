class UnboundedChannel(T) < Channel(T)
  def initialize
    @closed = false
    @queue = Deque(T).new
    @capacity = Int32::MAX
    @senders = Crystal::PointerLinkedList(Sender(T)).new
    @receivers = Crystal::PointerLinkedList(Receiver(T)).new
  end
end
