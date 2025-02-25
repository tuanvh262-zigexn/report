class TriggerUpdateSubjectRedmineWorker
  include Sidekiq::Worker

  def perform
    SubTask.joins(:story)
      .where.not(update_title: true)
      .merge(Story.where.not(issue_id: Settings.redmine.issue_id_valid))
      .each do |sub_task|
      SubTask::UpdateRedmineService.new(sub_task.id).execute
    end
  end
end
