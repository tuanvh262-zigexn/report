class UpdateStoryRedmineWorker
  include Sidekiq::Worker

  def perform
    Redmine::ListIssue.new.execute.each do |data|
      ForceUpdateStoryWorker.perform_async(data["id"], data["updated_on"])
    end
  end
end
