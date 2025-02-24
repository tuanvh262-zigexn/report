class UpdateRedmineIssueWorker
  include Sidekiq::Worker

  def perform redmine_issue_id, payload = nil
    Redmine::UpdateIssue.new(redmine_issue_id, payload).execute
  end
end
