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
end
