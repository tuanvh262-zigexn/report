class Redmine::UpdateIssue < Redmine::PutBase
  attr_reader :issue_id, :subject, :status

  def initialize issue_id, payload_json = {}.to_json
    @issue_id = issue_id
    payload = JSON.parse(payload_json)
    @subject = payload["subject"]
    @status = payload["status"]
  end

  private

  def full_url
    "https://dev.zigexn.vn/issues/#{issue_id}.json"
  end

  def body_payload
    issue = {}
    if subject
      issue[:subject] = subject
    elsif status
      issue[:status_id] = status
    end

    {
      issue: issue
    }
  end
end
