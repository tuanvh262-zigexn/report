class UpdateRedmineIssueWorker
  include Sidekiq::Worker

  def perform redmine_issue_id, payload = nil
    task = SubTask.find_by(issue_id: redmine_issue_id)

    return if task&.closed?

    Redmine::UpdateIssue.new(redmine_issue_id, payload).execute
  end
end
