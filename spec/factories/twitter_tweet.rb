FactoryBot.define do
  factory :twitter_tweet do
    association :twitter_search_source
    twitter_search { twitter_search_source&.twitter_search }

    date { Time.at(rand(Time.new(2008, 1, 1).to_i..Time.now.to_i)) }
    username { Faker::Internet.username }
    content { Faker::Lorem.paragraph }
    twitter_id { SecureRandom.uuid }
  end
end
