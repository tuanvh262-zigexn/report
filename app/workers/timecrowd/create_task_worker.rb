class Timecrowd::CreateTaskWorker
  include Sidekiq::Worker

  def perform data
    task = JSON.parse(data)

    return if TimecrowdTask.exists?(timecrowd_id: task["timecrowd_id"])

    TimecrowdTask.create!(task)
  end
end
