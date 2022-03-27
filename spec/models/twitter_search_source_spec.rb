require 'rails_helper'

RSpec.describe TwitterSearchSource, type: :model do
  describe 'validations' do
    subject { build(:twitter_search_source) }

    it { should belong_to(:twitter_search) }

    it { should validate_presence_of(:query) }
  end
end
