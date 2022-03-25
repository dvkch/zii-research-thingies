require 'rails_helper'

RSpec.describe ApplicationRecord, type: :model do
  describe 'translations' do
    def list_models
      ApplicationRecord.descendants.sort_by(&:name)
    end

    def list_attributes(klass)
      attributes = klass.attribute_names.dup

      # remove XXX_type attribute used by a polymorphic association
      attributes
        .filter { |a| a.end_with?('_type') }
        .map { |a| a.chomp('_type') }
        .filter { |a| attributes.include?("#{a}_id") }
        .each { |a| attributes.delete("#{a}_type") }

      # rename attributes to the actual attribute name used in models, forms, etc
      attributes = attributes.map do |a|
        next a if ['public_id', 'user_id'].include?(a)

        a = a.chomp('_data') if a.end_with?('_data')
        a = a.chomp('_id') if a.end_with?('_id')
        a = a.chomp('_ciphertext') if a.end_with?('_ciphertext')
        a = a.chomp('_i18n') if a.end_with?('_i18n')
        a
      end

      attributes.sort
    end

    def list_enums(klass)
      klass.defined_enums
    end

    def translated?(key)
      I18n.t(key, default: nil) != nil
    end

    it 'has a translated name for every class' do
      missing_translations = []

      [:en, :fr].each do |locale|
        I18n.with_locale(locale) do
          list_models.each do |klass|
            key_prefix = "activerecord.models.#{klass.name.underscore}"
            missing_translations << klass.name unless translated?("#{key_prefix}.one")
            missing_translations << klass.name unless translated?("#{key_prefix}.other")
          end
        end
      end

      expect(missing_translations.uniq).to eq []
    end

    it 'has a translated name for every attribute' do
      missing_translations = []

      [:en, :fr].each do |locale|
        I18n.with_locale(locale) do
          list_models.each do |klass|
            list_attributes(klass).each do |attribute|
              common_key = "attributes.#{attribute}"
              specific_key = "activerecord.attributes.#{klass.name.underscore}.#{attribute}"

              missing_translations << "#{klass}.#{attribute}" unless translated?(common_key) || translated?(specific_key)
            end
          end
        end
      end

      puts missing_translations.uniq

      expect(missing_translations.uniq).to eq []
    end

    it 'has a translated name for every enum value' do
      missing_translations = []

      [:en, :fr].each do |locale|
        I18n.with_locale(locale) do
          list_models.each do |klass|
            list_enums(klass).each do |enum, enum_config|
              enum_config.each_key do |value|
                key = "activerecord.enums.#{klass.name.underscore}.#{enum.pluralize}.#{value}"
                missing_translations << key unless translated?(key)
              end
            end
          end
        end
      end

      expect(missing_translations.uniq).to eq []
    end
  end
end
