module SqlSpecHelper
  def test_sql_predictability(validates_count = true, lambda_create, lambda_request)
    # the returned JSON includes associated models, meaning we need to take special care crafting our requests to
    # load all data in a deterministic number of requests, instead of loading data only when needed. this
    # is done via the `includes_associated` scope for most models

    # 1 object
    lambda_create.call
    sql_requests_1 = ActiveRecord::Base.count_queries do
      lambda_request.call
    end
    expect(response_page.count).to eq 1 if validates_count

    # 2 objects
    lambda_create.call
    sql_requests_2 = ActiveRecord::Base.count_queries do
      lambda_request.call
    end
    expect(response_page.count).to eq 2 if validates_count

    # test O(1)
    expect(sql_requests_2).to eq sql_requests_1
    Rails.logger.info "SQL request count is stable: #{sql_requests_1}"
  end
end

RSpec.configure do |config|
  config.include SqlSpecHelper, type: :request
  config.include SqlSpecHelper, type: :model
end
