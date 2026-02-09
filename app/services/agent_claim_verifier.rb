# frozen_string_literal: true

require 'net/http'
require 'resolv'
require 'json'

class AgentClaimVerifier < BaseService
  DNS_PREFIX = 'mastodon-agent-verify='.freeze

  def call(user, method, payload)
    return true if ENV['AGENT_CLAIM_BYPASS'] == 'true'

    case method
    when 'dns'
      verify_dns(payload['domain'], user.agent_verification_code)
    when 'github'
      verify_github(payload['gist_url'], user.agent_verification_code)
    when 'x'
      verify_x(payload['tweet_url'] || payload['proof'], user.agent_verification_code)
    else
      false
    end
  end

  private

  def verify_dns(domain, code)
    return false if domain.blank?

    Resolv::DNS.open do |dns|
      txt_records = dns.getresources(domain, Resolv::DNS::Resource::IN::TXT)
      txt_records.any? { |record| record.data.include?("#{DNS_PREFIX}#{code}") }
    end
  rescue Resolv::ResolvError
    false
  end

  def verify_github(url, code)
    return false if url.blank?

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.open_timeout = 5
    http.read_timeout = 5
    response = http.get(uri.request_uri)

    response.is_a?(Net::HTTPSuccess) && response.body.include?(code)
  rescue StandardError
    false
  end

  def verify_x(url, code)
    return false if url.blank?

    bearer = ENV['X_BEARER_TOKEN'].to_s
    return false if bearer.blank?

    tweet_id = extract_tweet_id(url)
    return false if tweet_id.blank?

    base = ENV.fetch('X_API_BASE', 'https://api.x.com')
    uri = URI.parse("#{base}/2/tweets/#{tweet_id}?tweet.fields=text,author_id,created_at")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.open_timeout = 5
    http.read_timeout = 5
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Authorization'] = "Bearer #{bearer}"

    response = http.request(request)
    return false unless response.is_a?(Net::HTTPSuccess)

    body = JSON.parse(response.body)
    text = body.dig('data', 'text').to_s
    text.include?(code)
  rescue StandardError
    false
  end

  def extract_tweet_id(url)
    match = url.to_s.match(%r{/(status|statuses)/(\d+)})
    match&.[](2)
  end
end
