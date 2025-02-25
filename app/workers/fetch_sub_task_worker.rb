class FetchSubTaskWorker
  include Sidekiq::Worker

  def perform sub_task_id, force_update = nil
    SubTask::FetchService.new(sub_task_id, force_update: force_update).execute
  end
end
