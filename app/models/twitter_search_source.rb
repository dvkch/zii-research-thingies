require 'twitter_service'

class TwitterSearchSource < ApplicationRecord
  belongs_to :twitter_search

  after_create :update_tweets
  after_update :update_tweets

  has_many :twitter_tweets, dependent: :destroy

  def display_name
    [
      query,
      "from: #{human_start_time}",
      "to: #{human_end_time}"
    ].join(', ')
  end

  def human_start_time
    start_time || '30 days ago'
  end

  def human_end_time
    end_time || (start_time ? start_time - 30.days : '30s ago')
  end

  # https://developer.twitter.com/en/docs/twitter-api/tweets/search/integrate/build-a-query
  def refresh_tweets
    TwitterTweet.transaction do
      twitter_tweets.delete_all

      TwitterService.new.load_tweets(self)
    end
  end

  def count_tweets
    TwitterService.new.count_tweets(self)
  end

  validates :query, presence: true

  protected

  def update_tweets
    # search params have changed, let's remove old results and pull new ones
    refresh_tweets if saved_change_to_query?
  end
end
