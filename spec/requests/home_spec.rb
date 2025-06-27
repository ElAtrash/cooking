require 'rails_helper'

RSpec.describe 'Home', type: :request do
  describe 'GET /' do
    it 'returns success' do
      get root_path
      expect(response).to be_successful
    end

    it 'displays welcome message' do
      get root_path
      expect(response.body).to include('Welcome to Your Rails 8 Starter Pack')
    end

    context 'when user is signed in' do
      let(:user) { create(:user) }

      before do
        post session_path, params: {
          email_address: user.email_address,
          password: 'password123'
        }
      end

      it 'displays user email' do
        get root_path
        expect(response.body).to include(user.email_address)
      end

      it 'shows sign out link' do
        get root_path
        expect(response.body).to include('Sign out')
      end
    end

    context 'when user is not signed in' do
      it 'shows sign in link' do
        get root_path
        expect(response.body).to include('Sign in')
      end

      it 'shows test credentials' do
        get root_path
        expect(response.body).to include('Try signing in with these test accounts')
      end
    end
  end
end
