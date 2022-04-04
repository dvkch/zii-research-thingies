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

  config.sort_order = 'date_desc'

  filter :twitter_search_source
  filter :username
  filter :content_includes, label: I18n.t('attributes.content'), as: :string
  filter :date
  filter :retweet_count
  filter :like_count
  filter :reply_count
  filter :quote_count

  includes :twitter_search, :twitter_search_source

  index as: ActiveAdmin::Views::IndexAsTableWithHeader do |_, part|
    if part == :header
      resource = TwitterSearch.find(params[:twitter_search_id])
      panel '' do
        # don't use .includes, we'd rather run 10 COUNT(*) queries than actually load in memory all tweets
        index_table_for(resource.twitter_search_sources, class: 'index_table') do
          column :query
          column :start_time, &:human_start_time
          column :end_time, &:human_end_time
          column :twitter_tweets do |resource|
            resource.twitter_tweets.size
          end
        end
      end
    end

    if part == :table
      id_column
      column :username
      column :content
      column :date
      column :twitter_search_source
      column :url do |resource|
        table_actions do
          item fa_icon('twitter', class: 'fab'), resource.url, class: 'member_link', target: '_blank'
        end
      end
      column :retweet_count
      column :like_count
      column :reply_count
      column :quote_count
      actions
    end
  end

  show do
    attributes_table title: I18n.t('attributes.content') do
      row :username
      row :content
      row :date
      row :url do |resource|
        table_actions do
          item fa_icon('twitter', class: 'fab'), resource.url, class: 'member_link', target: '_blank'
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

  action_item :open_twitter_search, only: :index, priority: 1 do
    resource = TwitterSearch.find(params[:twitter_search_id])
    link_to fa_icon('twitter', class: 'fab'), resource.twitter_url, class: 'button', target: '_blank'
  end

  action_item :edit_search, only: :index, priority: 2 do
    title = [I18n.t('common.actions.edit'), I18n.t('activerecord.models.twitter_search.one')].join(' ')
    link_to title, edit_admin_twitter_search_path(params[:twitter_search_id]), class: 'button'
  end

  action_item :delete_search, only: :index, priority: 3 do
    title = [I18n.t('common.actions.delete'), I18n.t('activerecord.models.twitter_search.one')].join(' ')
    link_to title, admin_twitter_search_path(params[:twitter_search_id]), class: 'button', method: :delete, data: { confirm: I18n.t('active_admin.delete_confirmation') }
  end
end
