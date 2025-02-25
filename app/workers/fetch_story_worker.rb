class FetchStoryWorker
  include Sidekiq::Worker

  def perform redmine_issue_id, force_update = nil
    Story::FetchService.new(redmine_issue_id, force_update: force_update).execute
  end
end
