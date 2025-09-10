class UpdateRedmineIssueWorker
  include Sidekiq::Worker

  def perform redmine_issue_id, payload = nil
    task = SubTask.without_parent_tasks.find_by(issue_id: redmine_issue_id)

    return if task&.closed? && JSON.parse(payload)["subject"].nil?

    Redmine::UpdateIssue.new(redmine_issue_id, payload).execute
  end
end
