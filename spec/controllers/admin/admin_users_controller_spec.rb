require 'rails_helper'

RSpec.describe Admin::AdminUsersController, type: :feature do
  scenario 'reset password' do
    ActionMailer::Base.deliveries.clear
    admin = create(:admin_user)
    password = 'my password'
    expect(admin.valid_password?(password)).to eq false

    visit new_admin_user_password_path
    expect(current_path).to eq new_admin_user_password_path

    fill_in 'admin_user[email]', with: admin.email
    click_button 'commit'

    expect(ActionMailer::Base.deliveries.size).to eq 1
    expect(ActionMailer::Base.deliveries.last).to be_valid_email
    expect(ActionMailer::Base.deliveries.last.from).to eq ['noreply@syan.me'] # default email
    expect(ActionMailer::Base.deliveries.last.to).to eq [admin.email]
    expect(ActionMailer::Base.deliveries.last.subject).to eq I18n.t('devise.mailer.reset_password_instructions.subject')
    expect(ActionMailer::Base.deliveries.last.text_part.body).to include edit_admin_user_password_path(reset_password_token: '')

    token = ActionMailer::Base.deliveries.last.text_part.body.to_s.string_between(edit_admin_user_password_path(reset_password_token: ''), "\n")
    visit edit_admin_user_password_path(reset_password_token: token)

    fill_in 'admin_user[password]', with: password
    fill_in 'admin_user[password_confirmation]', with: password
    click_button 'commit'

    expect(current_path).to eq admin_root_path
    expect(page).to have_text I18n.t('devise.passwords.updated')
    expect(admin.reload.valid_password?(password)).to eq true
  end
end
