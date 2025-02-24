class Report::GenerateService
  attr_accessor :team_report_id

  def initialize team_report_id
    @team_report_id = team_report_id
  end

  def execute
    return unless report

    ActiveRecord::Base.transaction do
      build_report_tasks

      report.update!(
        total_time_working: total_time_working,
        content: data_content,
        latest: true,
        public: set_public
      )
    end
  end

  private

  def report
    @report ||= TeamReport.find_by(id: team_report_id)
  end

  def working_logs
    @working_logs ||= begin
      if report.user_id
        UserWorkingLog.where(
          spent_on: report.start_date..report.end_date, user_id: report.user_id
        ).includes(:task, :story).to_a
      else
        UserWorkingLog.where(
          spent_on: report.start_date..report.end_date
        ).includes(:task, :story).to_a
      end
    end
  end

  def set_public
    working_logs.present?
  end

  def create_report_tasks
    @create_report_tasks ||= working_logs.select(&:owner_issue).map(&:task).compact.map(&:id) - report.tasks.pluck(:id)
  end

  def delete_report_tasks
    @delete_report_tasks ||= report.tasks.pluck(:id) - working_logs.select(&:owner_issue).map(&:task).compact.map(&:id)
  end

  def build_report_tasks
    working_logs.select(&:owner_issue).each do |working_log|
      next unless working_log.activity_for_story?

      if working_log.task&.id
        next unless create_report_tasks.include?(working_log.task&.id)
        ReportTask.create! team_report_id: report.id, sub_task_id: working_log.task&.id
      end
    end

    report.report_tasks.where(sub_task_id: delete_report_tasks).destroy_all
  end

  def data_content
    {
      not_found: working_logs.select(&:not_found?).sum(&:hours).to_f,
      requirement: working_logs.select(&:requirement?).sum(&:hours).to_f,
      design: working_logs.select{|x| x.design? && x.owner_issue}.sum(&:hours).to_f,
      coding: working_logs.select{|x| x.coding? && x.owner_issue}.sum(&:hours).to_f,
      testing: working_logs.select(&:testing?).sum(&:hours).to_f,
      bug_fixing: working_logs.select{|x| x.bug_fixing? && x.owner_issue}.sum(&:hours).to_f,
      release: working_logs.select(&:release?).sum(&:hours).to_f,
      meeting: working_logs.select(&:meeting?).sum(&:hours).to_f,
      leave_off: working_logs.select(&:leave_off?).sum(&:hours).to_f,
      document: working_logs.select(&:document?).sum(&:hours).to_f,
      support_customer: working_logs.select(&:support_customer?).sum(&:hours).to_f,
      idle: working_logs.select(&:idle?).sum(&:hours).to_f,
      support_team: working_logs.reject(&:owner_issue).sum(&:hours).to_f,
      doing_task: (working_logs.select(&:requirement?).sum(&:hours) +
        working_logs.select{|x| x.design? && x.owner_issue}.sum(&:hours) +
        working_logs.select{|x| x.coding? && x.owner_issue}.sum(&:hours) +
        working_logs.select(&:testing?).sum(&:hours) +
        working_logs.select(&:release?).sum(&:hours) +
        working_logs.select{|x| x.bug_fixing? && x.owner_issue}.sum(&:hours)).to_f,
      working_log: working_log_data,
      story_log: story_log_data
    }
  end

  def story_log_data
    testing_logs = working_logs.select{|x| ["testing"].include? x.activity_type}
    coding_logs = working_logs.select{|x| ["design", "coding", "bug_fixing"].include? x.activity_type}
    {
      coding: coding_logs.map(&:root_issue_id).uniq.count,
      testing: testing_logs.map(&:root_issue_id).uniq.count
    }
  end

  # def bug_chart_data
  #   tasks = report.tasks.uniq.to_a
  #   {
  #     total: tasks.count {|x| (x.kind == "bug") && (report.start_date..report.end_date).include?(x.redmine_created_at)}
  #     bugs: tasks.count{|x| x.is_bug && (report.start_date..report.end_date).include?(x.redmine_created_at)},
  #     prod_bugs: stories.sum(&:prod_bug_count),
  #   }
  # end

  # def task_chart_data
  #   tasks = report.tasks.uniq.to_a
  #     {
  #       total: tasks.size,
  #       done_tasks: tasks.count{|x| ['closed', 'released'].include?(x.status)},
  #       meeting_deadline: tasks.count{|x| x.meet_deadline}
  #     }
  # end

  # def story_chart_data
  #   stories = report.stories.uniq.to_a
  #   {
  #     total_tasks: stories.count,
  #     new_tasks: stories.count{|x| (report.start_date..report.end_date).include?(x.redmine_created_at)}
  #     waiting_release: stories.count{|x| ['waiting_release', 'verified', 'jp_side', 'closed', 'released'].include?(x.status)},
  #     released: stories.count{|x| ['closed', 'released'].include?(x.status)},
  #   }
  # end

  def working_log_data
    {
      difficulty_chart: working_log_difficulty_chart_data,
      difficulty_coding_chart: working_log_difficulty_coding_chart_data,
      difficulty_testing_chart: working_log_difficulty_testing_chart
    }
  end

  def working_log_difficulty_testing_chart
    logs = working_logs.select{|x| ["testing"].include? x.activity_type}
    {
      unset: logs.select(&:story_unset?).sum(&:hours).to_f,
      basic: logs.select(&:story_basic?).sum(&:hours).to_f,
      intermediate: logs.select(&:story_intermediate?).sum(&:hours).to_f,
      upper_intermediate: logs.select(&:story_upper_intermediate?).sum(&:hours).to_f,
      advanced: logs.select(&:story_advanced?).sum(&:hours).to_f,
      expert: logs.select(&:story_expert?).sum(&:hours).to_f,
    }
  end

  def working_log_difficulty_coding_chart_data
    logs = working_logs.select{|x| ["design", "coding", "bug_fixing"].include? x.activity_type}
    {
      unset: logs.select(&:story_unset?).sum(&:hours).to_f,
      basic: logs.select(&:story_basic?).sum(&:hours).to_f,
      intermediate: logs.select(&:story_intermediate?).sum(&:hours).to_f,
      upper_intermediate: logs.select(&:story_upper_intermediate?).sum(&:hours).to_f,
      advanced: logs.select(&:story_advanced?).sum(&:hours).to_f,
      expert: logs.select(&:story_expert?).sum(&:hours).to_f,
    }
  end

  def working_log_difficulty_chart_data
    logs = working_logs.select(&:activity_for_story?)
    {
      unset: logs.select(&:story_unset?).sum(&:hours).to_f,
      basic: logs.select(&:story_basic?).sum(&:hours).to_f,
      intermediate: logs.select(&:story_intermediate?).sum(&:hours).to_f,
      upper_intermediate: logs.select(&:story_upper_intermediate?).sum(&:hours).to_f,
      advanced: logs.select(&:story_advanced?).sum(&:hours).to_f,
      expert: logs.select(&:story_expert?).sum(&:hours).to_f,
    }
  end

  def total_time_working
    working_logs.select(&:activity_for_story?).sum(&:hours)
  end
end
