class Story < ApplicationRecord
  belongs_to :user, optional: true

  has_many :sub_tasks
  has_many :working_logs, class_name: UserWorkingLog.name,
    foreign_key: :root_issue_id, primary_key: :issue_id

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
    closed: 11
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
end
