class CategorizeActivitiesUserWorkingLogWorker
  include Sidekiq::Worker

  def perform user_working_log_id
    UserWorkingLogs::CategorizeActivities.new(user_working_log_id).execute
  end
end
