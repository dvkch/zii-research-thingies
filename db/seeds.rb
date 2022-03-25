if AdminUser.count.zero?
  AdminUser.create!(
    email: 'admin@example.com',
    first_name: 'Initial',
    last_name: 'Admin',
    password: 'best_password_ever',
    password_confirmation: 'best_password_ever',
    permissions: [:admin]
  )
end
