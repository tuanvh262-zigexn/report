class Redmine::CreateIssue < Redmine::PostBase
  attr_reader :payload

  def initialize payload_json = {}.to_json
    @payload = JSON.parse(payload_json)
  end

  private

  def full_url
    "https://dev.zigexn.vn/issues.json"
  end

  def body_payload
    {
      issue: {
        project_id: 17,
        tracker_id: 12,
        assigned_to_id: 276,
        subject: payload["subject"],
        custom_field_values: {
          16 => 'none',
          30 => 5
        }
      }
    }
  end
end
