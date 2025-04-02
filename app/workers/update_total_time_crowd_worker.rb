class UpdateTotalTimeCrowdWorker
  include Sidekiq::Worker

  def perform task_id
    TimeCrowdTask::UpdateService.new(task_id).execute
  end
end
