class FetchStoryWorker
  include Sidekiq::Worker

  def perform redmine_issue_id
    Story::FetchService.new(redmine_issue_id).execute
  end
end
