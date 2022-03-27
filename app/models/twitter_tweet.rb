class TwitterTweet < ApplicationRecord
  belongs_to :twitter_search
  belongs_to :twitter_search_source

  before_validation :set_twitter_search

  def url
    "https://twitter.com/#{username}/status/#{twitter_id}"
  end

  validates :date, presence: true
  validates :username, presence: true
  validates :content, presence: true
  validates :twitter_id, presence: true

  protected

  def set_twitter_search
    self.twitter_search_id = twitter_search_source&.twitter_search_id
  end
end
