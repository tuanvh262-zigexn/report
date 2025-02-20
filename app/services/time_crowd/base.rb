require "uri"
require "net/http"

class TimeCrowd::Base
  def execute
    url = URI(full_url)
    url.query = URI.encode_www_form(body_payload)
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(
      url,
      {
        Authorization: "Bearer Yw_S9unx388vx1sxAa957dzqZe0ayZCpKoGdORx_N3j5BlzhJQcD2zJXUqtqNIR-oROY1R6ZdIJ3Q0ir38m-pjSLaOyx9Q"
      }
    )
    # request.body = body_payload
    response = https.request(request)

    response_format(JSON.parse(response.read_body))
  end

  private

  def full_url
    raise NotImplementedError
  end

  def body_payload
    {}
  end

  def response_format data_json
    raise NotImplementedError
  end
end
