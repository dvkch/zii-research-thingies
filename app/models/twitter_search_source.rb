class TwitterSearchSource < ApplicationRecord
  belongs_to :twitter_search

  enum kind: {
    hashtag: 'hashtag',
    user: 'user'
  }

  validates :query, presence: true
  validates :kind, presence: true
end
