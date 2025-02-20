class SearchAllTimeCrowdTasksWorker
  include Sidekiq::Worker

  def perform
    Story.left_joins(:time_crowd_task)
      .merge(
        TimeCrowdTask.where(time_crowd_id: nil)
      ).each do |story|
      SearchTimeCrowdTaskWorker.perform_async(story.id)
    end
  end
end
