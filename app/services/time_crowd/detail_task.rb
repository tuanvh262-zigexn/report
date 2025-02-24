class TimeCrowd::DetailTask < TimeCrowd::Base
  attr_reader :time_crowd_id, :user_id

  def initialize time_crowd_id, user_id = nil
    @time_crowd_id = time_crowd_id
    @user_id = user_id
  end

  private

  def full_url
    "https://timecrowd.net/api/v2/tasks/#{time_crowd_id}?user_id=#{user_id}"
  end

  def response_format data_json
    data_json
  end
end
