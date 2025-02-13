class FetchUserWorkingLogWorker
  include Sidekiq::Worker

  def perform user_id, spent_on
    AsyncUserWorkingLogsService.new(user_id, spent_on).execute
  end
end
