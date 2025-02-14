class Report::GenerateService
  attr_accessor :team_report_id

  def initialize team_report_id
    @team_report_id = team_report_id
  end

  def execute
    return unless report

    ActiveRecord::Base.transaction do
      report.update!(
        total_time_working: total_time_working,
        content: data_content,
        latest: true,
        public: set_public
      )

      build_report_tasks
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
        ).includes(:task).to_a
      else
        UserWorkingLog.where(
          spent_on: report.start_date..report.end_date
        ).includes(:task).to_a
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
        working_logs.select{|x| x.bug_fixing? && x.owner_issue}.sum(&:hours)).to_f
    }
  end

  def total_time_working
    working_logs.select(&:activity_for_story?).sum(&:hours)
  end
end
