require 'rails_helper'

RSpec.describe ApplicationController, type: :request do
  describe 'locale' do
    it 'should set the current locale according to request headers' do
      I18n.locale = :fr

      get '/test_route', headers: { 'HTTP_ACCEPT_LANGUAGE': 'en,en-US,en-AU;q=0.8,fr;q=0.6,en-GB;q=0.4' }
      expect(I18n.locale).to eq :en

      get '/test_route', headers: { 'HTTP_ACCEPT_LANGUAGE': 'fr,fr-FR,fr-CA;q=0.8,en;q=0.4' }
      expect(I18n.locale).to eq :fr

      get '/test_route', headers: { 'HTTP_ACCEPT_LANGUAGE': 'it;q=0.8,en;q=0.4' }
      expect(I18n.locale).to eq :en

      get '/test_route', headers: { 'HTTP_ACCEPT_LANGUAGE': 'it;q=0.8,fr;q=0.4' }
      expect(I18n.locale).to eq :fr
    end
  end
end
