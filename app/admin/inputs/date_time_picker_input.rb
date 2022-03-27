# frozen_string_literal: true

class DateTimePickerInput
  def input_value
    return @input_value ||= options[:value] if options.key?(:value)

    @input_value ||= valid_object.send(valid_method)
  end

  def label_text
    super + ' (UTC)'
  end
end
