class Redmine::Issue < Redmine::GetBase
  attr_reader :issue_id, :cached

  def initialize issue_id, cached = true
    @issue_id = issue_id
    @cached = cached
  end

  private

  def full_url
    "https://dev.zigexn.vn/issues/#{issue_id}.json?include=children"
  end

  def response_format data_json
    data_json["issue"]
  end

  def use_cache
    cached
  end
end
