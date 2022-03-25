require 'rails_helper'

RSpec.describe String, type: :model do
  describe 'string_between' do
    it 'returns content between given delimiters' do
      string = 'i am a string with some content'
      expect(string.string_between('i am a', 'with')).to eq ' string '
    end

    it 'looks for second delimiter after position of the first' do
      string = 'i am a string with some content'
      expect(string.string_between('i am', 'a')).to eq ' '
    end

    it 'can keep delimiters' do
      string = 'i am a string with some content'
      expect(string.string_between('i am a', 'with', true)).to eq 'i am a string with'
    end

    it 'defaults to start/end if start/end delimiter cant be found' do
      string = 'i am a string with some content'
      expect(string.string_between(nil, 'with')).to eq 'i am a string '
      expect(string.string_between('i am not a', 'with')).to eq 'i am a string '
      expect(string.string_between('i am a', nil)).to eq ' string with some content'
      expect(string.string_between('i am a', 'withhh')).to eq ' string with some content'
    end
  end
end
