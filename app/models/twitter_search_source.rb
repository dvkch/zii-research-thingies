class TwitterSearchSource < ApplicationRecord
  belongs_to :twitter_search

  has_many :twitter_tweets, dependent: :destroy

  enum kind: {
    hashtag: 'hashtag',
    user: 'user'
  }

  def refresh_tweets
    puts "DO IT"
  end

  validates :query, presence: true
  validates :kind, presence: true
end
