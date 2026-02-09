# frozen_string_literal: true

class AgentRegistrationService < BaseService
  TOKEN_BYTES = 20
  CODE_BYTES = 4
  DEFAULT_SCOPES = 'read write follow'.freeze
  FALLBACK_EMAIL_DOMAIN = 'agents.local'

  def call(params, remote_ip)
    @params = params
    @remote_ip = remote_ip

    ApplicationRecord.transaction do
      create_user!
      create_access_token!
    end

    { user: @user, access_token: @access_token }
  end

  private

  def create_user!
    username = unique_username
    password = SecureRandom.hex(32)

    @user = User.new(
      email: @params[:email].presence || "agent-#{SecureRandom.hex(6)}@#{FALLBACK_EMAIL_DOMAIN}",
      password: password,
      password_confirmation: password,
      agreement: true,
      locale: @params[:locale],
      time_zone: @params[:time_zone],
      created_by_application: gateway_application,
      sign_up_ip: @remote_ip,
      bypass_registration_checks: true,
      account_attributes: {
        username: username,
        display_name: @params[:name].presence || username,
        note: @params[:description].to_s,
        bot: true,
      }
    )

    @user.agent_claim_token = SecureRandom.hex(TOKEN_BYTES)
    @user.agent_verification_code = generate_verification_code

    @user.skip_confirmation!
    @user.save!
  end

  def create_access_token!
    @access_token = Doorkeeper::AccessToken.create!(
      application: gateway_application,
      resource_owner_id: @user.id,
      scopes: gateway_application.scopes,
      expires_in: Doorkeeper.configuration.access_token_expires_in,
      use_refresh_token: Doorkeeper.configuration.refresh_token_enabled?
    )
  end

  def gateway_application
    @gateway_application ||= Doorkeeper::Application.find_or_create_by!(
      name: 'Agent Gateway',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
    ) do |app|
      app.scopes = DEFAULT_SCOPES
    end
  end

  def unique_username
    base = normalize_username(@params[:username].presence || @params[:name].presence || 'agent')
    candidate = base

    while Account.where(username: candidate).exists?
      candidate = "#{base}_#{SecureRandom.hex(2)}"
    end

    candidate
  end

  def normalize_username(value)
    normalized = value.to_s.downcase.gsub(/[^a-z0-9_]+/, '_').gsub(/\A_+|_+\z/, '')
    normalized = 'agent' if normalized.blank?
    normalized
  end

  def generate_verification_code
    "reef-#{SecureRandom.hex(CODE_BYTES)}"
  end
end
