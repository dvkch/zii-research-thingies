# frozen_string_literal: true

# https://gist.github.com/franks921/44509c65da3bea99bc49
class ArrayInput
  include Formtastic::Inputs::Base

  def to_html
    input_wrapping do
      inputs = []

      @object.send(method).each_with_index do |v, x|
        inputs << array_input_html(v, x)
      end

      label_html <<
        template.content_tag(:div, class: 'input-group--array') do
          inputs.join.html_safe << array_input_html('', 'new', false)
        end
    end
  end

  private

  def array_input_html(value, index, remove = true)
    if remove
      button = template.content_tag(
        :button,
        template.fa_icon('times'),
        class: 'array-action--remove js-remove-from-array-input',
        type: 'button'
      )
    else
      button = template.content_tag(
        :button,
        template.fa_icon('plus'),
        class: 'array-action--add js-add-to-array-input',
        type: 'button'
      )
    end

    html_options = {
      id: "#{object_name}_#{method}_#{index}"
    }
    if options[:element_kind] == :datetime
      html_options[:class] = 'date-time-picker-input'
      html_options[:maxlength] = 19
    end

    template.content_tag(:div, class: 'input-group--array__item') do
      template.text_field_tag("#{object_name}[#{method}][]", value, html_options) << button
    end
  end
end
