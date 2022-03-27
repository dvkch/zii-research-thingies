# frozen_string_literal: true

class Formtastic::Inputs::SelectInput
  def collection_from_enum
    if collection_from_enum?
      method_name = method.to_s

      enum_options_hash = object.defined_enums[method_name]
      enum_options_hash.map do |name, value|
        v = I18n.t("activerecord.enums.#{object.class.name.underscore}.#{method_name.pluralize}.#{name}", default: '-missing-')
        v = I18n.t("activerecord.enums.common.#{method_name.pluralize}.#{name}", default: name.humanize(keep_id_suffix: true)) if v == '-missing-'
        [v, name]
      end
    end
  end
end
