class TriggerTotalTimeCrowdWorker
  include Sidekiq::Worker

  def perform
    TimeCrowdTask.joins(:story).merge(
      Story.where.not(status: :closed)
    ).each do |task|
      UpdateTotalTimeCrowdWorker.perform_async(task.id)
    end
  end
end
