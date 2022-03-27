require 'twitter_service'

class TwitterSearchSource < ApplicationRecord
  belongs_to :twitter_search

  after_update_commit :remove_tweets

  has_many :twitter_tweets, dependent: :destroy

  enum kind: {
    hashtag: 'hashtag',
    user: 'user'
  }

  def display_name
    query
  end

  # https://developer.twitter.com/en/docs/twitter-api/tweets/search/integrate/build-a-query
  def refresh_tweets
    query = case kind
            when 'hashtag'
              "##{self.query}"
            when 'user'
              "from:#{self.query}"
            else
              raise 'unknown kind'
            end

    result = ::TwitterService.new.search(query)
    self.twitter_tweets = result
    save!
  end

  validates :query, presence: true
  validates :kind, presence: true

  protected

  def remove_tweets
    # search params have changed, let's remove old results
    twitter_tweets.destroy_all if query_changed? || kind_changed?
  end
end
