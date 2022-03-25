RSpec::Matchers.define :contain_keys do |*expected_format|
  require 'set'

  expected_format = expected_format.flatten

  match do |json_resource|
    json_resource.keys.to_set == expected_format.to_set
  end

  failure_message do |actual|
    difference = (expected_format - actual.keys).empty? ? actual.keys - expected_format : expected_format - actual.keys

    "expected #{expected_format.sort}
got #{actual.keys.sort}
difference #{difference.sort}
    "
  end
end
