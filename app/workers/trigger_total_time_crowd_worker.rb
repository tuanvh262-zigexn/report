class TriggerTotalTimeCrowdWorker
  include Sidekiq::Worker

  def perform
    Story.left_joins(:time_crowd_task)
      .where(
        status: [
          :init,
          :in_progress,
          :resolved,
          :code_review,
          :testing,
          :verified,
          :jp_side,
          :feedback,
          :ready_for_test
        ]
      ).merge(
        TimeCrowdTask.where.not(time_crowd_id: nil)
      ).each do |story|
      UpdateTotalTimeCrowdWorker.perform_async(story.id)
    end
  end
end
