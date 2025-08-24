class Redmine::TimeEntries < Redmine::GetBase
  attr_reader :user_id, :spent_on

  def initialize user_id, spent_on
    @user_id = user_id
    @spent_on = spent_on
  end

  private

  def full_url
    "https://dev.zigexn.vn/time_entries.json?user_id=#{user_id}&spent_on=#{spent_on}&project_id=17"
  end

  def response_format data_json
    data_json["time_entries"]
  end
end
