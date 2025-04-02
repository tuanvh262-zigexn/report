class SearchAllTimeCrowdTasksWorker
  include Sidekiq::Worker

  def perform
    Story.where.not(status: :closed).each do |story|
      SearchTimeCrowdTaskWorker.perform_async(story.id)
    end
  end
end
