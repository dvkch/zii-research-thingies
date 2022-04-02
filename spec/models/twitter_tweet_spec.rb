require 'rails_helper'

RSpec.describe TwitterTweet, type: :model do
  describe 'validations' do
    subject { build(:twitter_tweet) }

    it { should belong_to(:twitter_search) }
    it { should belong_to(:twitter_search_source) }

    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:twitter_id) }
  end

  describe 'common words' do
    it 'generates a list of the most common words used in tweets' do
      create(:twitter_search, allow_update: '1', twitter_search_sources: [
        source1 = build(:twitter_search_source, query: 'test 1'),
        source2 = build(:twitter_search_source, query: 'test 2')
      ])
      create(:twitter_tweet, twitter_search_source: source1, content: 'I am a rabbit')
      create(:twitter_tweet, twitter_search_source: source2, content: 'I love my rabbit')
      expect(TwitterTweet.common_words).to eq [['rabbit', 2], ['am', 1], ['my', 1], ['love', 1]]
      expect(TwitterTweet.common_words(limit: 1)).to eq [['rabbit', 2]]
      expect(TwitterTweet.common_words(min_word_length: 4)).to eq [['rabbit', 2], ['love', 1]]
      expect(source1.twitter_tweets.common_words).to eq [['rabbit', 1], ['am', 1]]
    end
  end
end
