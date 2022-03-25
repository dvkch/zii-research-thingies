module ApiAuthSpecHelpers
  module Requests
    def test_authentication(method, path, valid_status = 200, params = {})
      params_proc = params.is_a?(Proc) ? params : proc { params }

      # no configured client
      send(method, path, params: params_proc.call)
      expect(response.status).to eq 403
      expect(response_json['message']).to eq I18n.t('errors.messages.no_client_configured')

      client = create_and_log_client

      # no auth
      send(method, path, params: params_proc.call)
      expect(response.status).to eq 401
      expect(response_json['message']).to eq I18n.t('errors.messages.invalid_client')

      # valid auth
      send(method, path, params: params_proc.call, headers: common_api_headers)
      expect(response.status).to eq valid_status

      client.destroy!
    end
  end
end

RSpec.configure do |config|
  config.include ApiAuthSpecHelpers::Requests, type: :request
end
