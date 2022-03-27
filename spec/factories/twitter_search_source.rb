FactoryBot.define do
  factory :twitter_search_source do
    association :twitter_search
    kind { :user }
    query { 'syan_me' }
  end
end
