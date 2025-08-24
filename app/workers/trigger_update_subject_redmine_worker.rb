class TriggerUpdateSubjectRedmineWorker
  include Sidekiq::Worker

  def perform
    SubTask.without_parent_tasks.joins(:story)
      .where.not(update_title: true)
      .merge(Story.from_jp)
      .each do |sub_task|
      SubTask::UpdateRedmineService.new(sub_task.id).execute
    end
  end
end
