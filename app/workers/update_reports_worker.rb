class UpdateReportsWorker
  include Sidekiq::Worker

  def perform
    yesterday = Time.current.yesterday
    UserWorkingLog.where.not(standardized: true)
      .pluck(:spent_on).uniq.each do |spent_on|

      UserDailyReport.where(start_date: spent_on).update_all(latest: false)
      DailyReport.where(start_date: spent_on).update_all(latest: false)

      UserWeeklyReport.where(start_date: spent_on.beginning_of_week).update_all(latest: false)
      WeeklyReport.where(start_date: spent_on.beginning_of_week).update_all(latest: false)

      UserMonthlyReport.where(start_date: spent_on.beginning_of_month).update_all(latest: false)
      MonthlyReport.where(start_date: spent_on.beginning_of_month).update_all(latest: false)

      UserQuarterReport.where(start_date: spent_on.beginning_of_quarter).update_all(latest: false)
      QuarterReport.where(start_date: spent_on.beginning_of_quarter).update_all(latest: false)
    end
    UserWorkingLog.where.not(standardized: true).update_all(standardized: true)
  end
end
