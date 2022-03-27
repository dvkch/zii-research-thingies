# frozen_string_literal: true

ActiveAdmin.register TwitterTweet do
  menu parent: 'twitter', priority: 2
  belongs_to :twitter_search

  actions :index, :show

  filter :username
  filter :content
  filter :twitter_id

  includes :twitter_search_source

  index do
    selectable_column
    id_column
    column :username
    column :content
    column :date
    column :twitter_search_source
    column :url do |resource|
      table_actions do
        item I18n.t('common.actions.view'), resource.url, class: 'member_link', target: '_blank'
      end
    end
    actions
  end

  show do
    attributes_table title: I18n.t('attributes.content') do
      row :username
      row :content
      row :date
      row :url do |resource|
        table_actions do
          item I18n.t('common.actions.view'), resource.url, class: 'member_link', target: '_blank'
        end
      end
    end

    attributes_table title: I18n.t('admin.labels.stats') do
      row :retweet_count
      row :like_count
      row :reply_count
      row :quote_count
    end

    panel I18n.t('activerecord.models.twitter_tweet.one') do
      TwitterService.new.embed_html(resource.url).html_safe
    end

    # attributes_table title: I18n.t('admin.labels.metadata') do
    #   row :created_at
    #   row :updated_at
    # end
  end

  action_item :full_export, only: :index, priority: 1 do
    link_to I18n.t('admin.actions.refresh_tweets'), refresh_tweets_admin_twitter_search_twitter_tweets_path(twitter_search), method: :post
  end

  collection_action :refresh_tweets, method: :post do
    search = TwitterSearch.find(params[:twitter_search_id])
    search.refresh_tweets

    redirect_to admin_twitter_search_twitter_tweets_path(search), notice: 'Done √'
  end
end
