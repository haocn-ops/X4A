# frozen_string_literal: true

class ActivityPub::BaseController < Api::BaseController
  include SignatureVerification
  include AccountOwnedConcern

  skip_before_action :require_authenticated_user!
  skip_before_action :require_not_suspended!
  skip_around_action :set_locale
  before_action :reject_federation!, if: :federation_disabled?

  private

  def federation_disabled?
    Rails.configuration.x.mastodon.disable_federation
  end

  def reject_federation!
    head 404
  end

  def skip_temporary_suspension_response?
    false
  end
end
