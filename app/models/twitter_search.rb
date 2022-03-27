class TwitterSearch < ApplicationRecord
  has_many :twitter_search_sources, dependent: :destroy
  accepts_nested_attributes_for :twitter_search_sources, allow_destroy: true

  validates :name, presence: true
end
