class AsyncUserWorkingLogsService
  BATCH_SIZE = 1000

  attr_reader :user_id, :spent_on

  def initialize user_id, spent_on
    @user_id = user_id
    @spent_on = spent_on
  end

  def execute
    entries = Redmine::TimeEntries.new(user.redmine_id, spent_on).execute
    user_working_logs_new = []
    user_working_logs = []
    entries.map do |entry|
      working_log = UserWorkingLog.find_by(
        user: user,
        hours: entry["hours"],
        spent_on: entry["spent_on"],
        activity: entry.dig("activity", "name"),
        issue_id: entry.dig("issue", "id"),
        comments: entry["comments"],
        project_name: entry.dig("project", "name"),
      )
      user_working_logs << working_log&.id

      next if working_log&.id
      user_working_logs_new << UserWorkingLog.new(
        user: user,
        hours: entry["hours"],
        spent_on: entry["spent_on"],
        activity: entry.dig("activity", "name"),
        issue_id: entry.dig("issue", "id"),
        comments: entry["comments"],
        project_name: entry.dig("project", "name"),
      )
    end

    UserWorkingLog.where(user: user, spent_on: spent_on).where.not(id: user_working_logs.compact).destroy_all

    UserWorkingLog.import! user_working_logs_new, batch_size: BATCH_SIZE, validate: false

    UserWorkingLog.where(user: user, spent_on: spent_on).where.not(id: user_working_logs.compact).each do |log|
      CategorizeActivitiesUserWorkingLogWorker.perform_async(log.id)
    end
  end

  private

  def user
    @user ||= User.find_by(id: user_id)
  end
end
