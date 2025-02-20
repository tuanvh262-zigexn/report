class TimeCrowd::SearchTask < TimeCrowd::Base
  attr_reader :search_title

  def initialize search_title
    @search_title = search_title
  end

  private

  def full_url
    "https://timecrowd.net/api/v1/search/tasks"
  end

  def response_format data_json
    data_json["tasks"]
  end

  def body_payload
    {
      title: search_title
    }
  end
end
