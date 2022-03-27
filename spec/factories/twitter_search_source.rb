FactoryBot.define do
  factory :twitter_search_source do
    association :twitter_search
    query { 'from:syan_me' }
  end
end
