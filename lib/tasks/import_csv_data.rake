namespace :db do
  task :import_csv_data, [:models] => :environment do |_, args|
    csv_path = Rails.root.join "db", "fixtures", "#{args[:models]}.csv"
    ImportCsvService.new(args[:models], csv_path, false).execute
  end

  task import_master_data: :environment do
    %w(users).each do |model|
      csv_path = Rails.root.join "db", "fixtures", "#{model}.csv"
      ImportCsvService.new(model, csv_path, false).execute
    end

    reports = []
    ('2023-01-01'.to_date..Time.current.to_date).each do |t|
      User.all.each do |user|
        reports << UserDailyReport.new(user_id: user.id, content: {}, start_date: t)
      end
      reports << DailyReport.new(content: {}, start_date: t)
    end

    ('2023-01-01'.to_date..Time.current.to_date).map(&:beginning_of_week).uniq.each do |t|
      User.all.each do |user|
        reports << UserWeeklyReport.new(user_id: user.id, content: {}, start_date: t)
      end
      reports << WeeklyReport.new(content: {}, start_date: t)
    end

    ('2023-01-01'.to_date..Time.current.to_date).map(&:beginning_of_month).uniq.each do |t|
      User.all.each do |user|
        reports << UserMonthlyReport.new(user_id: user.id, content: {}, start_date: t)
      end
      reports << MonthlyReport.new(content: {}, start_date: t)
    end

    ('2023-01-01'.to_date..Time.current.to_date).map(&:beginning_of_quarter).uniq.each do |t|
      User.all.each do |user|
        reports << UserQuarterReport.new(user_id: user.id, content: {}, start_date: t)
      end
      reports << QuarterReport.new(content: {}, start_date: t)
    end
    TeamReport.import reports
  end

  task async_user_working_logs: :environment do
    User.all.each do |user|
      ('2023-01-01'.to_date..Time.current.to_date).each do |time|
        FetchUserWorkingLogWorker.perform_async(user.id, time.strftime('%Y-%m-%d'))
      end
    end
  end
end
