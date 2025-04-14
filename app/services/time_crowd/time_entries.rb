class TimeCrowd::TimeEntries < TimeCrowd::Base
  attr_reader :user_id, :date

  def initialize user_id, date
    @user_id = user_id
    @date = date
  end

  private

  def full_url
    "https://timecrowd.net/api/v2/calendar"
  end

  def response_format data_json
    data_json.find{|x| x["date"] == date}
  end

  def body_payload
    {
      date: date,
      user_id: user_id,
      view: 'daily'
    }
  end
end
