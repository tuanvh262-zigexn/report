class Story::FindTimeCrowdService
  attr_accessor :story_id

  def initialize story_id
    @story_id = story_id
  end

  def execute
    task = TimeCrowd::SearchTask.new(story.subject).execute.first

    if task
      time_crowd_task.assign_attributes(
        time_crowd_id: task["id"],
        total_time: task["total_time"],
        content: {}
      )
    else
      time_crowd_task.assign_attributes(
        content: {}
      )
    end

    time_crowd_task.save!
  end

  private

  def story
    @story ||= Story.find(story_id)
  end

  def time_crowd_task
    @time_crowd_task ||= TimeCrowdTask.find_or_initialize_by(story_id: story_id)
  end
end
