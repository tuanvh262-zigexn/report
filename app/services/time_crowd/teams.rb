class TimeCrowd::Teams < TimeCrowd::Base
  private

  def full_url
    "https://timecrowd.net/api/v1/teams"
  end

  def response_format data_json
    data_json
  end
end
