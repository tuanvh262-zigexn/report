class UpdateStoryRedmineWorker
  include Sidekiq::Worker

  def perform
    offset = 0

    loop do
      issues = Redmine::ListIssue.new(offset).execute
      break if issues.blank?

      issues.each do |data|
        ForceUpdateStoryWorker.perform_async(data["id"], data["updated_on"])
      end

      break if issues.size < 100
      offset += 100
    end
  end
end
