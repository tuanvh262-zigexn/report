class FetchSubTaskWorker
  include Sidekiq::Worker

  def perform sub_task_id
    SubTask::FetchService.new(sub_task_id).execute
  end
end
