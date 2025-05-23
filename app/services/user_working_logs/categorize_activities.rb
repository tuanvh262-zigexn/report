class UserWorkingLogs::CategorizeActivities
  attr_accessor :user_working_log_id, :root_issue, :activity_type

  def initialize user_working_log_id
    @user_working_log_id = user_working_log_id
    @activity_type = :not_found
  end

  def execute
    return unless user_working_log

    gen_activity_type
    user_working_log.update!(
      activity_type: activity_type,
      root_issue_id: root_issue["id"],
      standardized: false,
      owner_issue: owner_issue
    )
    if user_working_log.activity_for_story? || user_working_log.support_customer? || user_working_log.document?
      FetchStoryWorker.perform_async(user_working_log.root_issue_id)
    end
  end

  private

  def user_working_log
    @user_working_log ||= UserWorkingLog.find_by(id: user_working_log_id)
  end

  def get_redmine_issue issue_id
    return unless issue_id
    @root_issue = Redmine::Issue.new(issue_id).execute
  end

  def gen_activity_type
    redmine_issue = get_redmine_issue(user_working_log.issue_id)
    times_fetch_redmine = 0
    while redmine_issue
      if times_fetch_redmine == 0 && activity_type == :not_found
        Settings.regex.user_working_log.activity_types.out_task.each do |type, regex|
          @activity_type = type if redmine_issue.dig("subject")&.match(regex)
          break if activity_type != :not_found
        end
      end

      if times_fetch_redmine == 1 && activity_type == :not_found
        Settings.regex.user_working_log.activity_types.on_task.each do |type, regex|
          @activity_type = type if redmine_issue.dig("subject")&.match(regex)
          break if activity_type != :not_found
        end
      end

      times_fetch_redmine += 1
      redmine_issue = get_redmine_issue(redmine_issue.dig("parent", "id"))
    end
  end

  def owner_issue
    return true unless user_working_log.user.dev?
    return true unless [:requirement, :coding, :design, :bug_fixing, :testing, :release].include? activity_type
    root_issue.dig("assigned_to", "id") == user_working_log.user.redmine_id
  end
end
