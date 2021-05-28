require "socket"
require "./outgoing_packet"

class MMO::Connection(T) < IO
  include Loggable

  @send_queue = Deque(OutgoingPacket(T)).new
  @send_queue_mutex = Mutex.new(:Reentrant)
  @pending_close = false

  getter address : Socket::IPAddress
  property! client : T?
  property? wants_to_write : Bool = false

  def initialize(manager : PacketManager(T), socket : TCPSocket, tcp_nodelay : Bool)
    @manager = manager
    @socket = socket
    @address = socket.remote_address
    socket.tcp_nodelay = tcp_nodelay
  end

  def read(*args)
    @socket.read(*args)
  end

  def write(*args) : Nil
    @socket.write(*args)
  end

  def ip : String
    @address.address
  end

  def send_packet(op : OutgoingPacket(T))
    return if @pending_close

    send_queue do |queue|
      queue << op
      @wants_to_write = true
    end
  end

  def close
    @pending_close = true
  end

  def close(op : OutgoingPacket(T)?)
    close({op})
  end

  def close(packets : Enumerable(OutgoingPacket(T)?))
    send_queue do |queue|
      unless @pending_close
        @pending_close = true
        queue.clear
        unless packets.empty?
          packets.each { |op| queue << op if op }
          @manager.close_connection(self)
        end
      end
    end

    @wants_to_write = false
  end

  def closed? : Bool
    @pending_close
  end

  def send_queue(&block : Deque(OutgoingPacket(T)) ->)
    @send_queue_mutex.synchronize { yield @send_queue }
  end

  def to_s(io : IO)
    io.print("Connection(", ip, ')')
  end
end
