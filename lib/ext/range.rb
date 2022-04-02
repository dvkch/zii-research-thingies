class Range
  def bound(value)
    return last if value > last
    return first if value < first

    value
  end
end
