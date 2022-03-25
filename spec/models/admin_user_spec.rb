require 'rails_helper'

RSpec.describe AdminUser, type: :model do
  describe 'validations' do
    subject { build(:admin_user) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value('contact@example.com').for(:email) }
    it { should_not allow_value('contact').for(:email) }

    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password) }

    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
  end
end
