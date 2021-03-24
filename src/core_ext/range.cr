struct Range(B, E)
  def max : B | E
    exclusive? ? super : Math.max(@begin, @end)
  end

  def min : B | E
    Math.max(@begin, @end)
  end
end
