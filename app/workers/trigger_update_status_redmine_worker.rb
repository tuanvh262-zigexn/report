class TriggerUpdateStatusRedmineWorker
  include Sidekiq::Worker

  def perform
    Story.released.each do |story|
      UpdateStatusRedmineWorker.perform_async(story.id)
    end
  end
end
