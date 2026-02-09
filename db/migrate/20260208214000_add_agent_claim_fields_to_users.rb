# frozen_string_literal: true

class AddAgentClaimFieldsToUsers < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :users, :agent_claim_token, :string
    add_column :users, :agent_verification_code, :string
    add_column :users, :agent_claim_submitted_at, :datetime
    add_column :users, :agent_claimed_at, :datetime
    add_column :users, :agent_verification_method, :string
    add_column :users, :agent_verification_payload, :jsonb

    add_index :users, :agent_claim_token, unique: true, algorithm: :concurrently
  end
end
