class SubTask::FetchService
  attr_accessor :sub_task_id

  def initialize sub_task_id
    @sub_task_id = sub_task_id
  end

  def execute
    ActiveRecord::Base.transaction do
      sub_task.assign_attributes(
        owner_id: user&.id,
        status: status,
        subject: redmine_issue.dig("subject"),
        start_date: redmine_issue.dig("start_date"),
        due_date: redmine_issue.dig("start_date"),
        done_ratio: redmine_issue.dig("done_ratio").to_i,
        total_estimated_hours: redmine_issue.dig("total_estimated_hours"),
        total_spent_hours: redmine_issue.dig("total_spent_hours"),
        time_estimate_ratio: time_estimate_ratio,
        bug_category: bug_category,
        defect_origin: defect_origin,
        cause_analyze: redmine_issue["custom_fields"]&.find{|x| x["name"] == "Cause Analyze"}.try("[]", "value"),
        is_bug: is_bug?,
        meet_deadline: meet_deadline,
        activity_type: gen_activity_type
      )

      sub_task.save!
    end
  end

  private

  def sub_task
    @sub_task ||= SubTask.find_by(id: sub_task_id)
  end

  def redmine_issue
    @redmine_issue ||= Redmine::Issue.new(sub_task.issue_id).execute
  end

  def redmine_parent_issue
    @redmine_parent_issue ||= Redmine::Issue.new(redmine_issue.dig("parent", "id")).execute
  end

  def gen_activity_type
    Settings.regex.sub_task.activity_types.each do |type, regex|
      return type if redmine_parent_issue.dig("subject")&.match(regex)
    end
  end

  def user
    @user ||= User.find_by(redmine_id: user_redmine_id)
  end

  def user_redmine_id
    redmine_issue.dig("assigned_to", "id")
  end

  def meet_deadline
    buffer_rate = (user&.buffer_rate || 0.8)
    buffer_rate < time_estimate_ratio && time_estimate_ratio <= 1
  end

  def status
    SubTask.statuses[redmine_issue.dig("status", "name").downcase.gsub(" ", "_")] || 0
  end

  def time_estimate_ratio
    return 0 if redmine_issue.dig("total_estimated_hours").to_i.zero?
    redmine_issue.dig("total_spent_hours") / redmine_issue.dig("total_estimated_hours")
  end

  def bug_category
    redmine_issue["custom_fields"]&.find{|x| x["name"] == "Bug category"}.try("[]", "value")
      &.split("-")&.first.to_i
  end

  def defect_origin
    redmine_issue["custom_fields"]&.find{|x| x["name"] == "Defect Origin"}
      .try("[]", "value")&.split(" ", 2)&.last&.gsub(" ", "_")&.downcase || 0
  end

  def is_bug?
    sub_task.kind == "bug" && !redmine_issue.dig("subject").match("Not bug")
  end
end
