struct Set(T)
  def reject!(& : T ->)
    each { |e| delete(e) if yield e }
    self
  end
end
