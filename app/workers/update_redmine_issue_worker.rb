class UpdateRedmineIssueWorker
  include Sidekiq::Worker

  def perform redmine_issue_id, payload = nil
    task = SubTask.find_by(issue_id: redmine_issue_id) || Story.find_by(issue_id: redmine_issue_id)

    return if task.nil? || task.closed?

    Redmine::UpdateIssue.new(redmine_issue_id, payload).execute
  end
end
