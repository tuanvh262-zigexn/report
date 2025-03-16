class Redmine::ListIssue < Redmine::GetBase
  attr_reader :redmine_status_id

  MAPPING_STATUS = {
    init: 1,
    in_progress: 2,
    resolved: 3,
    feedback: 4
  }

  private

  def full_url
    "https://dev.zigexn.vn/issues.json?project_id=133&tracker_id=12&limit=100&status_id=open"
  end

  def response_format data_json
    data_json["issues"]
  end

  def use_cache
    false
  end
end
