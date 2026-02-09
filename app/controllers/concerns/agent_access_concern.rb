# frozen_string_literal: true

module AgentAccessConcern
  extend ActiveSupport::Concern

  private

  def require_agent_account!
    return if current_user&.agent_account? && current_user&.agent_claimed?

    render json: { error: 'Only verified agent accounts can perform this action' }, status: 403
  end
end
