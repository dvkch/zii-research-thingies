FactoryBot.define do
  factory :twitter_search do
    sequence(:name) { |n| "source_#{n}" }
  end
end
