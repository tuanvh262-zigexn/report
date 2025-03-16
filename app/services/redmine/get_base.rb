require "uri"
require "net/http"

class Redmine::GetBase
  def execute
    fetch_or_compute("redmine_#{full_url}") {
      url = URI(full_url)
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request.basic_auth(ENV['BASIC_AUTH_USER_NAME'], ENV['BASIC_AUTH_USER_PASSWORD'])

      request["X-Redmine-API-Key"] = ENV['REDMINE_API_KEY']
      response = https.request(request)

      response_format(JSON.parse(response.read_body))
    }
  end

  private

  def full_url
    raise NotImplementedError
  end

  def response_format data_json
    raise NotImplementedError
  end

  def use_cache
    true
  end

  def fetch_or_compute(key, expires_in: 5.minutes)
    if use_cache
      Rails.cache.fetch(key, expires_in: expires_in) { yield }
    else
      yield
    end
  end
end
