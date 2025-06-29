# frozen_string_literal: true

module ControllerTestHelpers
  def sign_in(user)
    # Mock Rails 8 authentication system
    session = user.session.create!(user_agent: "Test Agent", ip_address: "127.0.0.1")
    Current.session = session
    allow(Current).to receive(:session).and_return(session)
    allow(Current).to receive(:user).and_return(user)
    allow(controller).to receive(:authenticated?).and_return(true)

    # Set the session cookie for the test
    cookies.signed[:session_id] = session.id
  end

  def sign_out
    Current.session&.destroy
    Current.session = nil
    allow(Current).to receive(:session).and_return(nil)
    allow(Current).to receive(:user).and_return(nil)
    allow(controller).to receive(:authenticated?).and_return(false)

    cookies.delete(:session_id)
  end
end

RSpec.configure do |config|
  config.include ControllerTestHelpers, type: :controller
end
