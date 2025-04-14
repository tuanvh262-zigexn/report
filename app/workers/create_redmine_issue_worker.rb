class CreateRedmineIssueWorker
  include Sidekiq::Worker

  def perform payload = nil
    Redmine::CreateIssue.new(payload).execute
  end
end
