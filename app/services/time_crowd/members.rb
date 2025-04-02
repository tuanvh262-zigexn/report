class TimeCrowd::Members < TimeCrowd::Base
  attr_reader :team_id

  def initialize team_id
    @team_id = team_id
  end

  private

  def full_url
    "https://timecrowd.net/api/v2/teams/#{team_id}/memberships"
  end

  def response_format data_json
    data_json
  end
end
