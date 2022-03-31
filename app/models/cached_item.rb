class CachedItem < ApplicationRecord
  def self.fetch(key, &block)
    item = CachedItem.find_by_key(key)

    if item.nil?
      item = CachedItem.create(key: key)
      item.value = block.call
      item.save
    end

    item.value
  end

  validates :key, presence: true, uniqueness: true
end
