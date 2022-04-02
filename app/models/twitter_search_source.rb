require 'twitter_service'

class TwitterSearchSource < ApplicationRecord
  belongs_to :twitter_search

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

  def refresh_tweets_if_needed
    if saved_change_to_query? || saved_change_to_start_time? || saved_change_to_end_time?
      refresh_tweets
    end
  end

  def count_tweets
    TwitterService.new.count_tweets(self)
  rescue ZiiResearchThingies::Error => e
    errors.add(:query, e.message)
    0
  end

  validates :query, presence: true
end
