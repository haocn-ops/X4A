# frozen_string_literal: true

Rails.configuration.x.mastodon.disable_federation = ENV['DISABLE_FEDERATION'] == 'true'
