# frozen_string_literal: true

class ActiveAdmin::Views::IndexAsTable::IndexTableFor
  builder_method :index_table_for
end

class ActiveAdmin::Views::TableFor
  def view_actions(name = '', options = {})
    # we use this instead of the defaults (show, edit, delete) to prevent confusion. if an admin user is viewing a
    # playlist's content, it would show a "delete" button, that allows deleting the actual track, not the link between
    # the track and the playlist itself
    column name, options do |resource|
      table_actions do
        default_actions_show(resource, css_class: :member_link)
      end
    end
  end

  def view_edit_actions(name = '', options = {})
    # we use this instead of the defaults (show, edit, delete) to prevent confusion. if an admin user is viewing a
    # playlist's content, it would show a "delete" button, that allows deleting the actual track, not the link between
    # the track and the playlist itself
    column name, options do |resource|
      table_actions do
        default_actions_show_edit(resource, css_class: :member_link)
      end
    end
  end

  private

  def default_actions_show(resource, options = {})
    if controller.action_methods.include?('show') && authorized?(ActiveAdmin::Auth::READ, resource)
      item I18n.t('common.actions.view'), resource_path(resource), class: "view_link #{options[:css_class]}", title: I18n.t('common.actions.view')
    end
  end

  def default_actions_show_edit(resource, options = {})
    if controller.action_methods.include?('show') && authorized?(ActiveAdmin::Auth::READ, resource)
      item I18n.t('common.actions.view'), resource_path(resource), class: "view_link #{options[:css_class]}", title: I18n.t('common.actions.view')
    end
    if controller.action_methods.include?('edit') && authorized?(ActiveAdmin::Auth::UPDATE, resource)
      item I18n.t('common.actions.edit'), edit_resource_path(resource), class: "edit_link #{options[:css_class]}", title: I18n.t('common.actions.edit')
    end
  end
end

module CustomColumnAndRowTypes
  def self.get_value(resource, attributes, attr_block)
    return attr_block.call(resource) if attr_block

    value = resource
    attributes.each do |attr|
      next if attr == :self
      value = value&.send(attr)
    end
    value
  end

  def self.container(context, col_or_row, data_type, attributes, attr_block, &block)
    attributes = [attributes] unless attributes.is_a?(Array)

    attribute_name = attributes.last
    attribute_name = context.instance_variable_get(:@resource_class)&.name if attribute_name == :self

    classes = "#{col_or_row}-#{attribute_name} #{col_or_row}-#{data_type}"

    case col_or_row
    when :row
      context.row attribute_name, class: classes do |resource|
        value = get_value(resource, attributes, attr_block)
        block.call(resource, attributes, value)
      end

    when :column
      context.column attribute_name, class: classes do |resource|
        value = get_value(resource, attributes, attr_block)
        block.call(resource, attributes, value)
      end

    else
      raise Enso::Error, 'Unknown admin display type'
    end
  end

  def self.anonymized(context, type, attr, &block)
    container(context, type, :anonymized, attr, block&.to_proc) do |resource, attributes, _|
      resource.try(attributes.last).present? ? true : false
    end
  end

  def self.image(context, type, attr, &block)
    container(context, type, :image, attr, block&.to_proc) do |resource, attributes, _|
      thumb_url = resource.send(attributes.last, :thumb)&.url
      original_url = resource.send(attributes.last)&.url
      unless thumb_url.nil?
        context.image_tag(thumb_url, style: 'display: block;') << context.link_to(I18n.t('admin.labels.original'), original_url, target: '_blank')
      end
    end
  end

  def self.video(context, type, attr, &block)
    container(context, type, :video, attr, block&.to_proc) do |resource, attributes, _|
      thumb_url = resource.send(attributes.last, :thumb)&.url
      original_url = resource.send(attributes.last)&.url
      unless thumb_url.nil?
        context.image_tag(thumb_url, style: 'display: block;') << context.link_to(I18n.t('admin.labels.original'), original_url, target: '_blank')
      end
    end
  end

  def self.sound(context, type, attr, &block)
    container(context, type, :sound, attr, block&.to_proc) do |resource, _, value|
      unless value.nil?
        value = value.url if value.respond_to?(:url)
        context.audio_tag(value, style: 'display: block;', class: 'sound-preview', controls: '', preload: 'metadata') << context.link_to(I18n.t('admin.labels.original'), value, target: '_blank')
      end
    end
  end

  def self.text(context, type, attr, &block)
    container(context, type, :text, attr, block&.to_proc) do |_, _, value|
      value&.start_with?('<p>') ? value.html_safe : value&.line_breaks_to_html
    end
  end

  def self.html(context, type, attr, &block)
    container(context, type, :html, attr, block&.to_proc) do |_, _, value|
      value&.html_safe
    end
  end

  def self.code(context, type, attr, &block)
    container(context, type, :code, attr, block&.to_proc) do |_, _, value|
      context.tag(:pre) << value
    end
  end

  def self.preview(context, type, attr, &block)
    container(context, type, :preview, attr, nil) do |resource, _, value|
      [
        CGI.escapeHTML(value),
        '<span class="attribute-preview">' + CGI.escapeHTML(block&.call(resource) || '') + '</span>'
      ].join.html_safe
    end
  end

  def self.color(context, type, attr, &block)
    container(context, type, :color, attr, block&.to_proc) do |_, _, value|
      if value
        context.content_tag(:span, '', class: 'attribute-color', style: "background: #{value}") << value.to_s.upcase
      end
    end
  end

  def self.country(context, type, attr, &block)
    container(context, type, :country, attr, block&.to_proc) do |_, _, value|
      country = nil
      country = ISO3166::Country.find_country_by_alpha3(value) unless value.nil?
      if country.nil?
        nil
      else
        country.name
      end
    end
  end

  def self.language(context, type, attr, &block)
    container(context, type, :language, attr, block&.to_proc) do |_, _, value|
      language = nil
      language = ISO::Language.find(value) unless value.nil?
      if language.nil?
        nil
      else
        language.name
      end
    end
  end

  def self.file(context, type, attr, &block)
    container(context, type, :file, attr, block&.to_proc) do |resource, attributes, value|
      file_name = value&.original_filename || I18n.t('common.actions.download')
      thumb_url = resource.send(attributes.last, :thumb)&.url
      original_url = resource.send(attributes.last)&.send(:url, filename: file_name, disposition: 'attachment')

      if original_url.nil?
        nil
      elsif type == :column
        context.link_to file_name, original_url
      else
        context.image_tag(thumb_url, style: 'display: block;') << context.link_to(file_name, original_url, target: '_blank', download: file_name)
      end
    end
  end

  def self.i18n(context, type, attr, &block)
    container(context, type, :i18n, attr, block&.to_proc) do |resource, attributes, _|
      values = resource.send("#{attributes.last}_i18n")
      if values.empty?
        nil

      elsif type == :column
        available_locales = I18n.available_locales
                                .select { |locale| values[locale].present? }
                                .map { |locale| I18n.t("activerecord.enums.common.locales.#{locale}") }
        value = resource.send(attributes.last)
        context.content_tag(:span, available_locales.join(''), class: 'attribute-i18n') << value&.to_s

      else
        I18n
          .available_locales
          .select { |locale| values[locale].present? }
          .map { |locale| context.content_tag(:span, I18n.t("activerecord.enums.common.locales.#{locale}"), class: 'attribute-i18n') << values[locale]&.to_s }
          .join('<br />').html_safe
      end
    end
  end

  def self.enum(context, type, attr, &block)
    container(context, type, :enum, attr, block&.to_proc) do |resource, attributes, value|
      if value.nil?
        nil
      else
        v = I18n.t("activerecord.enums.#{resource.class.name.underscore}.#{attributes.first.to_s.pluralize}.#{value}", default: '-missing-')
        v = I18n.t("activerecord.enums.common.#{attributes.first.to_s.pluralize}.#{value}", default: value.humanize(keep_id_suffix: true)) if v == '-missing-'
        v
      end
    end
  end

  def self.view(context, type, attr, &block)
    container(context, type, :view, attr, block&.to_proc) do |_, _, value|
      if value.nil?
        nil
      else
        context.table_actions do
          context.item I18n.t('common.actions.view'), context.auto_url_for(value), class: 'member_link'
        end
      end
    end
  end

  def self.edit(context, type, attr, &block)
    container(context, type, :edit, attr, block&.to_proc) do |_, _, value|
      if value.nil?
        nil
      else
        context.table_actions do
          context.item I18n.t('common.actions.edit'), context.edit_resource_path(value), class: 'member_link'
        end
      end
    end
  end

  def self.many(context, type, attr, &block)
    container(context, type, :many, attr, block&.to_proc) do |_, _, value|
      value.map { |t| context.auto_link(t) }.join('<br>').html_safe if value
    end
  end
end

class ActiveAdmin::Views::AttributesTable
  def anonymized_row(*attr, &block)
    CustomColumnAndRowTypes.anonymized(self, :row, attr, &block)
  end

  def img_row(*attr, &block)
    CustomColumnAndRowTypes.image(self, :row, attr, &block)
  end

  def video_row(*attr, &block)
    CustomColumnAndRowTypes.video(self, :row, attr, &block)
  end

  def sound_row(*attr, &block)
    CustomColumnAndRowTypes.sound(self, :row, attr, &block)
  end

  def text_row(*attr, &block)
    CustomColumnAndRowTypes.text(self, :row, attr, &block)
  end

  def html_row(*attr, &block)
    CustomColumnAndRowTypes.html(self, :row, attr, &block)
  end

  def code_row(*attr, &block)
    CustomColumnAndRowTypes.code(self, :row, attr, &block)
  end

  def preview_row(*attr, &block)
    CustomColumnAndRowTypes.preview(self, :row, attr, &block)
  end

  def color_row(*attr, &block)
    CustomColumnAndRowTypes.color(self, :row, attr, &block)
  end

  def country_row(*attr, &block)
    CustomColumnAndRowTypes.country(self, :row, attr, &block)
  end

  def language_row(*attr, &block)
    CustomColumnAndRowTypes.language(self, :row, attr, &block)
  end

  def file_row(*attr, &block)
    CustomColumnAndRowTypes.file(self, :row, attr, &block)
  end

  def i18n_row(*attr, &block)
    CustomColumnAndRowTypes.i18n(self, :row, attr, &block)
  end

  def enum_row(*attr, &block)
    CustomColumnAndRowTypes.enum(self, :row, attr, &block)
  end

  def view_row(*attr, &block)
    CustomColumnAndRowTypes.view(self, :row, attr, &block)
  end

  def edit_row(*attr, &block)
    CustomColumnAndRowTypes.edit(self, :row, attr, &block)
  end

  def many_row(*attr, &block)
    CustomColumnAndRowTypes.many(self, :row, attr, &block)
  end
end

class ActiveAdmin::Views::TableFor
  include ::ActiveAdminFixResourcesPaths

  def anonymized_column(*attr, &block)
    CustomColumnAndRowTypes.anonymized(self, :column, attr, &block)
  end

  def img_column(*attr, &block)
    CustomColumnAndRowTypes.image(self, :column, attr, &block)
  end

  def video_column(*attr, &block)
    CustomColumnAndRowTypes.video(self, :column, attr, &block)
  end

  def sound_column(*attr, &block)
    CustomColumnAndRowTypes.sound(self, :column, attr, &block)
  end

  def text_column(*attr, &block)
    CustomColumnAndRowTypes.text(self, :column, attr, &block)
  end

  def code_column(*attr, &block)
    CustomColumnAndRowTypes.code(self, :column, attr, &block)
  end

  def color_column(*attr, &block)
    CustomColumnAndRowTypes.color(self, :column, attr, &block)
  end

  def country_column(*attr, &block)
    CustomColumnAndRowTypes.country(self, :column, attr, &block)
  end

  def language_column(*attr, &block)
    CustomColumnAndRowTypes.language(self, :column, attr, &block)
  end

  def file_column(*attr, &block)
    CustomColumnAndRowTypes.file(self, :column, attr, &block)
  end

  def i18n_column(*attr, &block)
    CustomColumnAndRowTypes.i18n(self, :column, attr, &block)
  end

  def enum_column(*attr, &block)
    CustomColumnAndRowTypes.enum(self, :column, attr, &block)
  end

  def view_column(*attr, &block)
    CustomColumnAndRowTypes.view(self, :column, attr, &block)
  end

  def edit_column(*attr, &block)
    CustomColumnAndRowTypes.edit(self, :column, attr, &block)
  end

  def many_column(*attr, &block)
    CustomColumnAndRowTypes.many(self, :column, attr, &block)
  end

  def game_type_rule_column(*attr)
    column attr.first do |resource|
      if resource.send(attr.first.to_s + '_enabled')
        resource.send(attr.first)
      else
        false
      end
    end
  end
end
