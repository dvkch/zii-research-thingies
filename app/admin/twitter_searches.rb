# frozen_string_literal: true

ActiveAdmin.register TwitterSearch do
  menu parent: 'twitter', priority: 1

  permit_params :name, twitter_search_sources_attributes: [:id, :_destroy, :kind, :query, :include_replies]

  filter :name

  includes :twitter_search_sources

  index do
    selectable_column
    id_column
    column :name
    column :twitter_search_sources do |resource|
      resource.twitter_search_sources.map { |q| "#{q.kind}: #{q.query}" }.join('<br/>').html_safe
    end
    actions
  end

  show do
    attributes_table do
      row :name
    end

    panel I18n.t('attributes.twitter_search_sources') do
      index_table_for(resource.twitter_search_sources, class: 'index_table') do
        enum_column :kind
        column :query
      end
    end

    attributes_table title: I18n.t('admin.labels.metadata') do
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :name
    end

    f.inputs class: 'inputs has_many_table' do
      f.has_many(
        :twitter_search_sources,
        new_record: [I18n.t('common.actions.create'), I18n.t('activerecord.models.twitter_search_source.one')].join(' '),
        remove_record: [I18n.t('common.actions.delete'), I18n.t('activerecord.models.twitter_search_source.one')].join(' '),
        allow_destroy: ->(_) { true }
      ) do |param|
        param.semantic_errors
        param.input :kind, as: :select, placeholder: I18n.t('attributes.kind'), selected: param.object.kind || 'hashtag'
        param.input :query, placeholder: I18n.t('attributes.query')
        param.input :include_replies
      end
    end

    f.actions
  end
end
