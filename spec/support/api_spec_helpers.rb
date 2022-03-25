module ApiSpecHelpers
  module JSONHelpers
    def response_json
      return '' if response.body == ''

      JSON.parse(response.body)
    end

    def response_page(root = nil)
      return '' if response.body == ''

      json = JSON.parse(response.body)
      json = json[root] unless root.nil?
      return nil if json.nil?

      expect(page_keys_v1 - json.keys).to eq []
      expect(json['total'] >= json['items'].count).to eq true if json.keys.include?('total')
      json.fetch('items', nil)
    end
  end

  module Features
    def current_query_params
      uri = URI.parse(current_url)
      CGI.parse(uri.query || '')
    end

    def create_and_log_admin(params = {})
      params = { email: 'admin@example.com', password: '1234567890', permissions: [:admin] }.merge(params)
      admin = create(:admin_user, params)

      visit '/admin/login'
      fill_in 'admin_user[email]', with: params[:email]
      fill_in 'admin_user[password]', with: params[:password]
      click_button 'commit'

      expect(current_path).to eq '/admin'
      admin
    end

    def log_in_admin(admin, password)
      reset_session!

      visit '/admin/login'
      fill_in 'admin_user[email]', with: admin.email
      fill_in 'admin_user[password]', with: password
      click_button 'commit'

      expect(current_path).to eq '/admin'
    end
  end

  module Requests
    include JSONHelpers
    include FactoryBot::Syntax::Methods

    def create_and_log_client(params = {})
      params = { name: 'test client' }.merge(params)
      client = Client.create!(params)
      @client = client
      client
    end

    def log_in_client(client)
      @client = client
    end

    def create_and_log_admin(params = {})
      params = { email: 'admin@example.com', password: '1234567890', permissions: [:admin] }.merge(params)
      admin = create(:admin_user, params)

      post '/admin/login', params: { admin_user: params.slice(:email, :password) }
      expect(response.status).to eq 302

      admin
    end

    def log_in_admin(admin, password)
      post '/admin/login', params: { admin_user: { email: admin.email, password: password } }
      expect(response.status).to eq 302
    end

    def common_api_headers(skip_user_token = false)
      headers = {
        HTTP_ACCEPT: 'application/json'
      }
      headers['HTTP_X_CLIENT'] = @client if defined?(@client)
      headers['HTTP_AUTHORIZATION'] = "Bearer #{@token}" if defined?(@token) && !@token.nil? && !skip_user_token
      headers['HTTP_ACCEPT_LANGUAGE'] = I18n.locale.to_s
      headers
    end

    def track_keys
      %w[id kind file track_masters_count created_at updated_at]
    end

    def track_master_keys
      %w[id status file preset_slug preset created_at updated_at]
    end

    def preset_keys
      Preset::ATTRIBUTES.keys.map(&:to_s)
    end
  end
end

RSpec.configure do |config|
  config.include ApiSpecHelpers::Features, type: :feature
  config.include ApiSpecHelpers::Requests, type: :request
  config.include ApiSpecHelpers::Requests, type: :model
end
