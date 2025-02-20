class Redmine::ListIssue < Redmine::Base
  attr_reader :redmine_status_id

  MAPPING_STATUS = {
    init: 1,
    in_progress: 2,
    resolved: 3,
    feedback: 4
  }

  def initialize redmine_status_id
    @redmine_status_id = MAPPING_STATUS[redmine_status_id.to_sym]
  end

  private

  def full_url
    "https://dev.zigexn.vn/issues.json?project_id=157&tracker_id=12&limit=100&status_id=#{redmine_status_id}"
  end

  def response_format data_json
    data_json["issues"]
  end
end
