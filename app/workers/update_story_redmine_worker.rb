class UpdateStoryRedmineWorker
  include Sidekiq::Worker

  def perform status
    Redmine::ListIssue.new(status).execute.each do |story|
      FetchStoryWorker.perform_async(story["id"])
    end
  end
end
