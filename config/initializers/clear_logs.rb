if Rails.env.development? || Rails.env.test?
  `rake log:clear`
end
