class UpdateStatusRedmineWorker
  include Sidekiq::Worker

  def perform story_id
    Story::UpdateStatusRedmineService.new(story_id).execute
  end
end
