# frozen_string_literal: true

ActiveAdmin.register TwitterSearch do
  menu parent: 'twitter', priority: 1

  permit_params :name, :allow_update, twitter_search_sources_attributes: [:id, :_destroy, :query, :end_time, :start_time]

  filter :name

  includes :twitter_search_sources

  index do
    selectable_column
    id_column
    column :name
    many_column :twitter_search_sources
    column :twitter_tweets do |resource|
      resource.twitter_tweets.size
    end
    actions
  end

  controller do
    def show
      redirect_to admin_twitter_search_twitter_tweets_path(resource)
    end
  end

  show do
    attributes_table do
      row :name
    end

    panel I18n.t('attributes.twitter_search_sources') do
      index_table_for(resource.twitter_search_sources.includes(:twitter_tweets), class: 'index_table') do
        column :query
        column :start_time, &:human_start_time
        column :end_time, &:human_end_time
        column :twitter_tweets do |resource|
          resource.twitter_tweets.size
        end
      end
      para class: 'inline' do
        link_to fa_icon('twitter', class: 'fab'), resource.twitter_url, class: 'button', target: '_blank'
      end
      para class: 'inline' do
        link_to I18n.t('admin.actions.see_tweets'), admin_twitter_search_twitter_tweets_path(resource), class: 'button'
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

    f.inputs class: 'inputs has_many' do
      f.has_many(
        :twitter_search_sources,
        new_record: [I18n.t('common.actions.create'), I18n.t('activerecord.models.twitter_search_source.one')].join(' '),
        remove_record: [I18n.t('common.actions.delete'), I18n.t('activerecord.models.twitter_search_source.one')].join(' '),
        allow_destroy: ->(_) { true }
      ) do |param|
        param.input :query, as: :text, input_html: { maxlength: 1024 }, placeholder: I18n.t('attributes.query'), hint: '<a href="https://developer.twitter.com/en/docs/twitter-api/tweets/search/integrate/build-a-query#list" target="_blank">Building a query</a>'.html_safe
        param.input :start_time, as: :date_time_picker, hint: 'By default, a request will return Tweets from up to 30 days ago if you do not include this parameter.'
        param.input :end_time, as: :date_time_picker, hint: 'If used without start_time, Tweets from 30 days before end_time will be returned by default. If not specified, end_time will default to [now - 30 seconds].'
      end
    end

    if !f.object.errors.key?(:estimated_count)
      f.actions do
        f.action(:submit, label: I18n.t('admin.actions.count_tweets'))
        f.cancel_link
      end
    else
      f.inputs do
        count = f.object.errors.messages[:estimated_count].first.to_i
        f.input :allow_update, as: :boolean, label: I18n.t('admin.actions.allow_search_update_with_estimated_count', count: number_with_delimiter(count, delimiter: ' '))
      end
      f.actions
    end
  end

  after_create do |resource|
    resource.refresh_tweets_if_needed if resource.errors.empty?
  end

  after_update do |resource|
    resource.refresh_tweets_if_needed if resource.errors.empty?
  end
end
