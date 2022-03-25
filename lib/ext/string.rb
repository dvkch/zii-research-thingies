# frozen_string_literal: true

class String
  def string_between(delimiter1, delimiter2, keep_delimiters = false)
    if delimiter1
      pos1 = index(delimiter1)
      pos1 += delimiter1.size unless pos1.nil? || keep_delimiters
    end
    pos1 ||= 0

    if delimiter2
      pos2 = index(delimiter2, pos1)
      pos2 -= 1 unless pos2.nil?
      pos2 += delimiter2.size if pos2.present? && keep_delimiters
    end
    pos2 ||= size - 1

    self[pos1..pos2]
  end
end
