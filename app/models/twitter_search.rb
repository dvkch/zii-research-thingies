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

  def refresh_tweets_if_needed
    twitter_search_sources.each(&:refresh_tweets_if_needed)
  end

  def twitter_url
    query = twitter_search_sources.map { |s| "(#{s.query})" }.join(' OR ')
    uri = URI::HTTPS.build(host: 'twitter.com', path: '/search', query: URI.encode_www_form(q: query, src: 'typed_query'))
    uri.to_s
  end

  validates :name, presence: true
  validate :handle_admin_update

  attr_accessor :allow_update

  def handle_admin_update
    return if allow_update == '1'

    errors.add(:estimated_count, count_tweets)
  end
end
