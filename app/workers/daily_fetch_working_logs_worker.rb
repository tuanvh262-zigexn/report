class DailyFetchWorkingLogsWorker
  include Sidekiq::Worker

  def perform
    User.all.each do |user|
      ((Date.current-1.months)..Date.current).each do |time|
        FetchUserWorkingLogWorker.perform_async(user.id, time.strftime('%Y-%m-%d'))
      end
    end
  end
end
