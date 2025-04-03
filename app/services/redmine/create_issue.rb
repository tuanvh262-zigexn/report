class Redmine::CreateIssue < Redmine::PostBase

  def initialize payload_json = {}.to_json
    # payload = JSON.parse(payload_json)
  end

  private

  def full_url
    "https://dev.zigexn.vn/issues.json"
  end

  def body_payload
    # issue = {}
    # if subject
    #   issue[:subject] = subject
    # elsif status
    #   issue[:status_id] = status
    # end
    {
      issue: {
        project_id: 157,
        tracker_id: 12,
        assigned_to_id: 276,
        subject: "Test",
        custom_field_values: {
          16 => 'none',
          30 => 5
        }
      }
    }
  end
end
