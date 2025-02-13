class Redmine::Issue < Redmine::Base
  attr_reader :issue_id

  def initialize issue_id
    @issue_id = issue_id
  end

  private

  def full_url
    "https://dev.zigexn.vn/issues/#{issue_id}.json?include=children"
  end

  def response_format data_json
    data_json["issue"]
  end
end
