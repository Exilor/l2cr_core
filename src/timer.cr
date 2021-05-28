struct Timer
  def initialize
    @time = Time.monotonic
  end

  def start
    initialize
  end

  def result(precision : Int = 2) : Float64
    (Time.monotonic - @time).to_f.round(precision)
  end

  def to_s(io : IO)
    io.printf("%.4f", (Time.monotonic - @time).to_f)
  end
end
