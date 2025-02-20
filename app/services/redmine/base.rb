require "uri"
require "net/http"

class Redmine::Base
  def execute
    Rails.cache.fetch("redmine_#{full_url}", expires_in: 10.minutes) do
      url = URI(full_url)
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request.basic_auth(ENV['BASIC_AUTH_USER_NAME'], ENV['BASIC_AUTH_USER_PASSWORD'])

      request["X-Redmine-API-Key"] = ENV['REDMINE_API_KEY']
      response = https.request(request)

      response_format(JSON.parse(response.read_body))
    end
  end

  private

  def full_url
    raise NotImplementedError
  end

  def response_format data_json
    raise NotImplementedError
  end
end
