class TwitterSearch < ApplicationRecord
  has_many :twitter_search_sources, dependent: :destroy
  accepts_nested_attributes_for :twitter_search_sources, allow_destroy: true

  has_many :twitter_tweets, through: :twitter_search_sources

  def count_tweets
    twitter_search_sources.map(&:count_tweets).reduce(0, :+)
  end

  def refresh_tweets
    twitter_search_sources.each(&:refresh_tweets)
  end

  validates :name, presence: true
end
