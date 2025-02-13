class UserWorkingLog < ApplicationRecord
  belongs_to :user

  has_one :task, class_name: SubTask.name,
    foreign_key: :issue_id, primary_key: :issue_id

  enum :activity_type, {
    not_found: 0,
    requirement: 1,
    design: 2,
    coding: 3,
    testing: 4,
    bug_fixing: 5,
    release: 6,
    meeting: 7,
    leave_off: 8,
    document: 9,
    support_customer: 10,
    idle: 11
  }

  delegate :name, to: :user, allow_nil: true, prefix: true

  # def support_activity?
  #   coding? || design? || bug_fixing?
  # end

  def activity_for_story?
    requirement? || design? || coding? || testing? || bug_fixing? || release?
  end
end
