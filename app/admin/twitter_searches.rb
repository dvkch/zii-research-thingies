# frozen_string_literal: true

ActiveAdmin.register TwitterSearch do
  menu parent: 'twitter', priority: 1

  permit_params :name, twitter_search_sources_attributes: [:id, :_destroy, :query]

  filter :name

  includes :twitter_search_sources

  index do
    selectable_column
    id_column
    column :name
    many_column :twitter_search_sources
    column :twitter_tweets do |resource|
      table_actions do
        item I18n.t('common.actions.view'), admin_twitter_search_twitter_tweets_path(resource), class: 'member_link'
      end
    end
    column I18n.t('admin.groups.twitter') do |resource|
      table_actions do
        item fa_icon('twitter'), resource.twitter_url, class: 'member_link', target: '_blank'
      end
    end
    actions
  end

  show do
    attributes_table do
      row :name
    end

    panel I18n.t('attributes.twitter_search_sources') do
      index_table_for(resource.twitter_search_sources, class: 'index_table') do
        column :query
      end
    end

    panel I18n.t('attributes.twitter_tweets') do
      link_to I18n.t('admin.actions.see_tweets'), admin_twitter_search_twitter_tweets_path(resource), class: 'button'
    end

    panel I18n.t('admin.groups.twitter') do
      link_to fa_icon('twitter'), resource.twitter_url, class: 'button', target: '_blank'
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

    f.inputs class: 'inputs has_many' do
      f.has_many(
        :twitter_search_sources,
        new_record: [I18n.t('common.actions.create'), I18n.t('activerecord.models.twitter_search_source.one')].join(' '),
        remove_record: [I18n.t('common.actions.delete'), I18n.t('activerecord.models.twitter_search_source.one')].join(' '),
        allow_destroy: ->(_) { true }
      ) do |param|
        param.semantic_errors
        param.input :query, placeholder: I18n.t('attributes.query'), hint: '<a href="https://developer.twitter.com/en/docs/twitter-api/tweets/search/integrate/build-a-query#list" target="_blank">Building a query</a>'.html_safe
      end
    end

    f.actions
  end
end
