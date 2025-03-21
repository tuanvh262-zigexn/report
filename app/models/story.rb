class Story < ApplicationRecord
  belongs_to :user, optional: true

  has_many :sub_tasks
  has_many :working_logs, class_name: UserWorkingLog.name,
    foreign_key: :root_issue_id, primary_key: :issue_id

  has_one :time_crowd_task

  STATUS_DISPLAYS = {
    'init' => 'Init',
    'pending_review' => 'Pending Review',
    'in_progress' => 'In Progress',
    'resolved' => 'Resolved',
    'code_review' => 'Code Review',
    'testing' => 'Testing',
    'verified' => 'Verified',
    'jp_side' => 'JP Side',
    'feedback' => 'Feedback',
    'waiting_release' => 'Waiting Release',
    'released' => 'Released',
    'closed' => 'Closed',
    'ready_for_test' => 'Ready for Test',
  }.freeze

  enum :status, {
    init: 0,
    pending: 1,
    in_progress: 2,
    resolved: 3,
    code_review: 4,
    testing: 5,
    verified: 6,
    jp_side: 7,
    feedback: 8,
    waiting_release: 9,
    released: 10,
    closed: 11,
    ready_for_test: 12
  }

  enum :level, {
    unset: 0,
    basic: 1,
    intermediate: 2,
    upper_intermediate: 3,
    advanced: 4,
    expert: 5
  }

  delegate :name, to: :user, allow_nil: true, prefix: true
  delegate :time_crowd_id, :total_time, :total_second, to: :time_crowd_task, allow_nil: true
  delegate :content, to: :time_crowd_task, allow_nil: true, prefix: true

  def state_over_period_date period_date
    # return :release if
    [
      release: :bug_fixing_end_at,
      bug_fixing: :bug_fixing_start_at,
      testing: :testing_start_at,
      coding: :coding_start_at,
      design: :design_start_at,
      requirement: :requirement_start_at,
    ].each do |state, key|
      return state if (self.send(key).present? && self.send(key) < period_date)
    end
  end

  def status_display
    return if status.blank?

    STATUS_DISPLAYS[status]
  end
end
