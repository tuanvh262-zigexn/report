class SearchTimeCrowdTaskWorker
  include Sidekiq::Worker

  def perform story_id
    Story::FindTimeCrowdService.new(story_id).execute
  end
end
