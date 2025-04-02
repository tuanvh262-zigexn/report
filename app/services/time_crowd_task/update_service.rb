class TimeCrowdTask::UpdateService
  attr_accessor :task_id

  def initialize task_id
    @task_id = task_id
  end

  def execute
    if task
      time_crowd_task.update!(
        total_time: format_time(task["total_time"]),
        total_second: task["total_time"],
        content: content_data
      )
    else
      time_crowd_task.destroy!
    end
  end

  private

  def task
    @task ||= TimeCrowd::DetailTask.new(time_crowd_task.time_crowd_id).execute
  end

  def time_crowd_task
    @time_crowd_task ||= TimeCrowdTask.find(task_id)
  end

  def content_data
    {
      users: task["users"].map do |user|
        total_time = TimeCrowd::DetailTask.new(time_crowd_task.time_crowd_id, user["id"]).execute["total_time"]
        user.merge(
          {total_time: format_time(total_time)}
        )
      end
    }
  end

  def format_time(seconds)
    hours = seconds / 3600
    minutes = (seconds % 3600) / 60
    secs = seconds % 60
    format("%02d:%02d:%02d", hours, minutes, secs)
  end
end
