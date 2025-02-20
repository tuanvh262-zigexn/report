class UpdateStoryRedmineWorker
  include Sidekiq::Worker

  def perform
    [:init, :in_progress, :resolved, :feedback].each do |status|
      Redmine::ListIssue.new(:status).execute.each do |story|
        FetchStoryWorker.perform_async(story["id"])
      end
    end
  end
end
