class Story::UpdateTotalTimeCrowdService
  attr_accessor :story_id

  def initialize story_id
    @story_id = story_id
  end

  def execute
    raise ActiveRecord::RecordNotFound unless time_crowd_task

    time_crowd_task.update!(
      total_time: format_time(task["total_time"]),
      total_second: task["total_time"],
      content: content_data
    )
  end

  private

  def story
    @story ||= Story.find(story_id)
  end

  def task
    @task ||= TimeCrowd::DetailTask.new(time_crowd_task.time_crowd_id).execute
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

  def time_crowd_task
    @time_crowd_task ||= story.time_crowd_task
  end

  def format_time(seconds)
    hours = seconds / 3600
    minutes = (seconds % 3600) / 60
    secs = seconds % 60
    format("%02d:%02d:%02d", hours, minutes, secs)
  end
end
