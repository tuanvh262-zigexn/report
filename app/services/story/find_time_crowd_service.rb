class Story::FindTimeCrowdService
  attr_accessor :story_id

  ACTIVITY_TYPE_MAPPING_TEXT = [
    { type: "investigate", text: "「調査・Investigate」"},
    { type: "design", text: "「設計・Design」"},
    { type: "coding", text: "「実装・Code」"},
    { type: "testing", text: "「テスト・Test」"},
  ]

  def initialize story_id
    @story_id = story_id
  end

  def execute
    ACTIVITY_TYPE_MAPPING_TEXT.each do |data|
      next if activity_type_crowd_tasks.include? data[:type]

      search_task = "#{story.subject}#{data[:text]}"
      task = TimeCrowd::SearchTask.new(search_task).execute.first

      next unless task

      time_crowd_task = TimeCrowdTask.find_or_initialize_by(
        story_id: story_id,
        activity_type: data[:type]
      )

      time_crowd_task.assign_attributes(
        time_crowd_id: task["id"],
        total_time: task["total_time"],
        content: {}
      )

      time_crowd_task.save!
    end
  end

  private

  def story
    @story ||= Story.find(story_id)
  end

  def activity_type_crowd_tasks
    @activity_type_crowd_tasks ||= story.time_crowd_tasks.pluck :activity_type
  end
end
