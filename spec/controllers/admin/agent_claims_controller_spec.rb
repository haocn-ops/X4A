# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AgentClaimsController do
  render_views

  let(:current_user) { Fabricate(:admin_user) }

  before { sign_in current_user, scope: :user }

  describe 'GET #show' do
    let(:user) do
      Fabricate(
        :user,
        agent_claim_submitted_at: Time.now.utc,
        agent_verification_method: 'github',
        agent_verification_payload: {
          'gist_url' => 'https://gist.github.com/example/abc123',
          'proof' => 'https://github.com/example',
        }
      )
    end

    it 'renders verification links for github and proof payloads' do
      get :show, params: { id: user.id }

      expect(response).to have_http_status(200)
      expect(response.body)
        .to include('https://gist.github.com/example/abc123')
        .and include('https://github.com/example')
    end
  end
end
