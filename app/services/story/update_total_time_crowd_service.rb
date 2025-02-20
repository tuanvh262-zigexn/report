class Story::UpdateTotalTimeCrowdService
  attr_accessor :story_id

  def initialize story_id
    @story_id = story_id
  end

  def execute
    raise ActiveRecord::RecordNotFound unless time_crowd_task

    task = TimeCrowd::DetailTask.new(time_crowd_task.time_crowd_id).execute

    time_crowd_task.update!(total_time: format_time(task["total_time"]))
  end

  private

  def story
    @story ||= Story.find(story_id)
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
