class CreateReportWorker
  include Sidekiq::Worker

  def perform
    reports = []

    User.all.each do |user|
      unless UserDailyReport.exists?(user_id: user.id, start_date: Date.current)
        reports << UserDailyReport.new(user_id: user.id, content: {}, start_date: Date.current)
      end

      unless UserWeeklyReport.exists?(user_id: user.id, start_date: Date.current.beginning_of_week)
        reports << UserWeeklyReport.new(user_id: user.id, content: {}, start_date: Date.current.beginning_of_week)
      end

      unless UserMonthlyReport.exists?(user_id: user.id, start_date: Date.current.beginning_of_month)
        reports << UserMonthlyReport.new(user_id: user.id, content: {}, start_date: Date.current.beginning_of_month)
      end

      unless UserQuarterReport.exists?(user_id: user.id, start_date: Date.current.beginning_of_quarter)
        reports << UserQuarterReport.new(user_id: user.id, content: {}, start_date: Date.current.beginning_of_quarter)
      end
    end

    unless DailyReport.exists?(start_date: Date.current)
      reports << DailyReport.new(content: {}, start_date: Date.current)
    end

    unless WeeklyReport.exists?(start_date: Date.current.beginning_of_week)
      reports << WeeklyReport.new(content: {}, start_date: Date.current.beginning_of_week)
    end

    unless MonthlyReport.exists?(start_date: Date.current.beginning_of_month)
      reports << MonthlyReport.new(content: {}, start_date: Date.current.beginning_of_month)
    end

    unless QuarterReport.exists?(start_date: Date.current.beginning_of_quarter)
      reports << QuarterReport.new(content: {}, start_date: Date.current.beginning_of_quarter)
    end

    TeamReport.import reports
  end
end
