# frozen_string_literal: true

class AgentClaimPolicy < ApplicationPolicy
  def index?
    role.can?(:manage_users)
  end

  def show?
    role.can?(:manage_users)
  end

  def approve?
    role.can?(:manage_users)
  end

  def reject?
    role.can?(:manage_users)
  end
end
