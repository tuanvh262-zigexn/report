class CreateReportWorker
  include Sidekiq::Worker

  def perform date_execute = Date.current
    reports = []

    (date_execute - 1.weeks..date_execute).each do |date|
      User.all.each do |user|
        unless UserDailyReport.exists?(user_id: user.id, start_date: date)
          reports << UserDailyReport.new(user_id: user.id, content: {}, start_date: date)
        end

        unless UserWeeklyReport.exists?(user_id: user.id, start_date: date.beginning_of_week)
          reports << UserWeeklyReport.new(user_id: user.id, content: {}, start_date: date.beginning_of_week)
        end

        unless UserMonthlyReport.exists?(user_id: user.id, start_date: date.beginning_of_month)
          reports << UserMonthlyReport.new(user_id: user.id, content: {}, start_date: date.beginning_of_month)
        end

        unless UserQuarterReport.exists?(user_id: user.id, start_date: date.beginning_of_quarter)
          reports << UserQuarterReport.new(user_id: user.id, content: {}, start_date: date.beginning_of_quarter)
        end
      end

      unless DailyReport.exists?(start_date: date)
        reports << DailyReport.new(content: {}, start_date: date)
      end

      unless WeeklyReport.exists?(start_date: date.beginning_of_week)
        reports << WeeklyReport.new(content: {}, start_date: date.beginning_of_week)
      end

      unless MonthlyReport.exists?(start_date: date.beginning_of_month)
        reports << MonthlyReport.new(content: {}, start_date: date.beginning_of_month)
      end

      unless QuarterReport.exists?(start_date: date.beginning_of_quarter)
        reports << QuarterReport.new(content: {}, start_date: date.beginning_of_quarter)
      end
    end

    TeamReport.import reports
  end
end
