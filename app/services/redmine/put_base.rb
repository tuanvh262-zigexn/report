require "uri"
require "net/http"

class Redmine::PutBase
  def execute
    url = URI(full_url)
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Put.new(url)
    request.basic_auth(ENV['BASIC_AUTH_USER_NAME'], ENV['BASIC_AUTH_USER_PASSWORD'])

    request["Content-Type"] = "application/json"
    request["X-Redmine-API-Key"] = ENV['REDMINE_API_KEY']
    request.body = body_payload.to_json

    response = https.request(request)

    raise response.body unless response.is_a?(Net::HTTPSuccess)
  end

  private

  def full_url
    raise NotImplementedError
  end

  def body_payload
    raise NotImplementedError
  end
end
