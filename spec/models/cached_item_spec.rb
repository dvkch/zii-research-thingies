require 'rails_helper'

RSpec.describe CachedItem, type: :model do
  describe 'validations' do
    subject { CachedItem.new }

    it { should validate_presence_of(:key) }
    it { should validate_uniqueness_of(:key) }
  end

  describe 'fetch' do
    it 'obtains data from cache if available' do
      expect(CachedItem.find_by_key('test')).to eq nil

      CachedItem.fetch('test') { 'value' }
      expect(CachedItem.find_by_key('test')).not_to eq nil
      expect(CachedItem.find_by_key('test').value).to eq 'value'

      CachedItem.fetch('test') { 'value2' }
      expect(CachedItem.find_by_key('test').value).to eq 'value'
    end
  end
end
