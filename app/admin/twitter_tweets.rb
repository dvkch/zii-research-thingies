# frozen_string_literal: true

ActiveAdmin.register TwitterTweet do
  menu parent: 'twitter', priority: 2
  belongs_to :twitter_search

  controller do
    defaults finder: :find_by_twitter_id

    def show
      if resource.nil?
        resource = TwitterTweet.find(params[:id])
        return redirect_to admin_twitter_search_twitter_tweet_path(resource.twitter_search_id, resource.twitter_id)
      end
      super
    end
  end

  actions :index, :show

  config.sort_order = "date_desc"

  filter :username
  filter :content
  filter :twitter_id
  filter :retweet_count
  filter :like_count
  filter :reply_count
  filter :quote_count


  includes :twitter_search, :twitter_search_source

  index do
    id_column
    column :username
    column :content
    column :date
    column :twitter_search_source
    column :url do |resource|
      table_actions do
        item fa_icon('twitter'), resource.url, class: 'member_link', target: '_blank'
      end
    end
    column :retweet_count
    column :like_count
    column :reply_count
    column :quote_count
    actions
  end

  show do
    attributes_table title: I18n.t('attributes.content') do
      row :username
      row :content
      row :date
      row :url do |resource|
        table_actions do
          item fa_icon('twitter'), resource.url, class: 'member_link', target: '_blank'
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

  action_item :count_tweets, only: :index, priority: 1 do
    link_to I18n.t('admin.actions.count_tweets'), count_tweets_admin_twitter_search_twitter_tweets_path(twitter_search), method: :post
  end

  collection_action :count_tweets, method: :post do
    search = TwitterSearch.find(params[:twitter_search_id])
    count = search.count_tweets

    redirect_to admin_twitter_search_twitter_tweets_path(search), notice: I18n.t('admin.notices.twitter.estimated_count', count: count)
  end

  action_item :refresh_tweets, only: :index, priority: 2 do
    link_to I18n.t('admin.actions.refresh_tweets'), refresh_tweets_admin_twitter_search_twitter_tweets_path(twitter_search), method: :post
  end

  collection_action :refresh_tweets, method: :post do
    search = TwitterSearch.find(params[:twitter_search_id])
    search.refresh_tweets

    redirect_to admin_twitter_search_twitter_tweets_path(search), notice: I18n.t('admin.notices.twitter.refreshed_tweets')
  end
end
