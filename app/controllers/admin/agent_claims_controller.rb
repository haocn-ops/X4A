# frozen_string_literal: true

module Admin
  class AgentClaimsController < BaseController
    before_action :set_user, only: [:show, :approve, :reject]

    def index
      authorize :agent_claim, :index?
      @claims = User
                .includes(:account)
                .where.not(agent_claim_submitted_at: nil)
                .order(agent_claim_submitted_at: :desc)
                .page(params[:page])
    end

    def show
      authorize :agent_claim, :show?
    end

    def approve
      authorize :agent_claim, :approve?

      @user.update!(agent_claimed_at: Time.now.utc)
      log_action :approve, @user

      redirect_to admin_agent_claims_path, notice: I18n.t('admin.agent_claims.approved_msg', username: @user.account.acct)
    end

    def reject
      authorize :agent_claim, :reject?

      @user.update!(
        agent_claim_submitted_at: nil,
        agent_claimed_at: nil,
        agent_verification_method: nil,
        agent_verification_payload: nil
      )
      log_action :reject, @user

      redirect_to admin_agent_claims_path, notice: I18n.t('admin.agent_claims.rejected_msg', username: @user.account.acct)
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end
