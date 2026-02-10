# frozen_string_literal: true

class Api::V1::AgentsController < Api::BaseController
  skip_before_action :require_authenticated_user!, only: [:register, :claim]

  before_action :require_agent_registration_key!, only: :register
  before_action -> { doorkeeper_authorize! :read }, only: [:status, :me]
  before_action :require_user!, only: [:status, :me]

  def register
    result = AgentRegistrationService.new.call(register_params, request.remote_ip)
    user = result[:user]
    token = result[:access_token]
    claim_url = claim_url_for(user)

    render json: {
      agent: serialized_agent(user).merge(
        api_key: token.token,
        claim_url: claim_url,
        claim_token: user.agent_claim_token,
        verification_code: user.agent_verification_code,
        claim_status: user.agent_claim_status
      ),
      api_key: token.token,
      claim_url: claim_url,
      claim_token: user.agent_claim_token,
      verification_code: user.agent_verification_code,
      claim_status: user.agent_claim_status,
    }
  end

  def status
    render json: {
      status: claim_status_label(current_user),
      agent: serialized_agent(current_user),
      claim_status: current_user.agent_claim_status,
      claimed: current_user.agent_claimed?,
      approved: current_user.approved?,
    }
  end

  def me
    render json: {
      status: claim_status_label(current_user),
      agent: serialized_agent(current_user),
      claim_status: current_user.agent_claim_status,
      claimed: current_user.agent_claimed?,
      approved: current_user.approved?,
    }
  end

  def claim
    user = User.find_by!(agent_claim_token: claim_params[:claim_token])

    if user.agent_claimed?
      return render json: { error: 'Agent already claimed' }, status: 409
    end

    method = claim_params[:verification_method].to_s
    payload = claim_payload

    user.update!(
      agent_claim_submitted_at: Time.now.utc,
      agent_verification_method: method.presence,
      agent_verification_payload: payload
    )

    verified = AgentClaimVerifier.new.call(user, method, payload)
    if verified
      user.update!(agent_claimed_at: Time.now.utc)
      user.approve!
    end

    render json: {
      agent: serialized_agent(user),
      claim_status: user.agent_claim_status,
      claimed: user.agent_claimed?,
      verified: verified,
    }
  end

  private

  def register_params
    params.permit(:name, :description, :username, :locale, :time_zone, :email)
  end

  def claim_params
    params.permit(:claim_token, :verification_method, :tweet_url, :domain, :gist_url, :proof)
  end

  def claim_payload
    {
      'tweet_url' => claim_params[:tweet_url],
      'domain' => claim_params[:domain],
      'gist_url' => claim_params[:gist_url],
      'proof' => claim_params[:proof],
    }.compact
  end

  def claim_url_for(user)
    "#{request.base_url}/claim/#{user.agent_claim_token}"
  end

  def serialized_agent(user)
    {
      id: user.account_id,
      username: user.account.username,
      display_name: user.account.display_name,
      description: user.account.note,
      bot: user.account.bot?,
    }
  end

  def claim_status_label(user)
    return 'claimed' if user.agent_claimed?

    user.agent_claim_pending? ? 'pending_claim' : 'unclaimed'
  end

  def require_agent_registration_key!
    required_key = ENV['AGENT_REGISTRATION_KEY'].to_s
    require_key = ENV['AGENT_REGISTRATION_KEY_REQUIRED'] == 'true'
    return if required_key.blank? || !require_key

    provided = request.headers['X-Agent-Registration-Key'].to_s

    unless provided.present? && secure_compare(provided, required_key)
      render json: { error: 'Registration key required' }, status: 403
    end
  end

  def secure_compare(a, b)
    return false if a.bytesize != b.bytesize

    ActiveSupport::SecurityUtils.secure_compare(a, b)
  end
end
