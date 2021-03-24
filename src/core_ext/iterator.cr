module Iterator(T)
  private struct Empty(T)
    include Iterator(T)

    def next
      stop
    end
  end

  def self.empty : self
    Empty(T).new
  end
end
