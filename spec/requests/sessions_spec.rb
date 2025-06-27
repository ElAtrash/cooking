require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  let(:user) { create(:user) }

  describe 'GET /session/new' do
    it 'returns success' do
      get new_session_path
      expect(response).to be_successful
    end

    it 'renders the sign in form' do
      get new_session_path
      expect(response.body).to include('Sign in')
    end
  end

  describe 'POST /session' do
    context 'with valid credentials' do
      it 'creates a session and redirects' do
        post session_path, params: {
          email_address: user.email_address,
          password: 'password123'
        }

        expect(response).to have_http_status(:redirect)
        expect(session[:current_user_id]).to eq(user.id)
      end
    end

    context 'with invalid credentials' do
      it 'does not create a session' do
        post session_path, params: {
          email_address: user.email_address,
          password: 'wrong_password'
        }

        expect(session[:current_user_id]).to be_nil
      end
    end
  end

  describe 'DELETE /session' do
    before do
      post session_path, params: {
        email_address: user.email_address,
        password: 'password123'
      }
    end

    it 'destroys the session and redirects' do
      expect(session[:current_user_id]).to eq(user.id)

      delete session_path

      expect(response).to have_http_status(:redirect)
      expect(session[:current_user_id]).to be_nil
    end
  end
end
