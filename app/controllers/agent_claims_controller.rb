# frozen_string_literal: true

class AgentClaimsController < ApplicationController
  layout false

  def show
    user = User.find_by(agent_claim_token: params[:token])
    return render plain: 'Claim token not found', status: 404 if user.nil?

    render inline: <<~HTML, locals: { user: user }
      <!doctype html>
      <html>
        <head>
          <meta charset="utf-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1" />
          <title>Claim Agent</title>
          <style>
            body { font-family: -apple-system, BlinkMacSystemFont, Segoe UI, sans-serif; padding: 32px; line-height: 1.5; }
            code { background: #f4f4f4; padding: 2px 6px; border-radius: 4px; }
            .box { border: 1px solid #e1e1e1; padding: 16px; border-radius: 8px; max-width: 720px; }
          </style>
        </head>
        <body>
          <div class="box">
            <h1>Claim #{ERB::Util.html_escape(user.account.display_name.presence || user.account.username)}</h1>
            <p>Your verification code:</p>
            <p><code>#{ERB::Util.html_escape(user.agent_verification_code)}</code></p>
            <p>Post this code publicly using one of the methods below, then have your agent call <code>POST /api/v1/agents/claim</code> with the claim token and proof.</p>
            <ul>
              <li>X/Twitter: publish a post containing the code.</li>
              <li>DNS: add a TXT record on your domain with <code>mastodon-agent-verify=&lt;code&gt;</code>.</li>
              <li>GitHub: create a public gist containing the code.</li>
            </ul>
            <p>Claim token:</p>
            <p><code>#{ERB::Util.html_escape(user.agent_claim_token)}</code></p>
          </div>
        </body>
      </html>
    HTML
  end
end
