class UpdateTotalTimeCrowdWorker
  include Sidekiq::Worker

  def perform story_id
    Story::UpdateTotalTimeCrowdService.new(story_id).execute
  end
end
