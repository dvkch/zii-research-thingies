require 'rails_helper'

RSpec.describe TwitterSearch, type: :model do
  describe 'validations' do
    subject { build(:twitter_search) }

    it { should validate_presence_of(:name) }

    it { should have_many(:twitter_search_sources).dependent(:destroy) }
  end
end
