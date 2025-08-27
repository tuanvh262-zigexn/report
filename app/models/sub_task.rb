class SubTask < ApplicationRecord
  default_scope { order(:issue_id)}

  belongs_to :story
  belongs_to :owner, class_name: User.name, foreign_key: :owner_id, optional: true
  belongs_to :parent, class_name: SubTask.name,
    foreign_key: :parent_task_id, primary_key: :issue_id, optional: true

  has_many :children, class_name: SubTask.name,
    foreign_key: :parent_task_id, primary_key: :issue_id

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

  enum :bug_category, {
    bug_category_unset: 0,
    requirement_notDefine: 1,
    misunderstand: 2,
    careless_mistake: 3,
    assumption: 4,
    coding_logic: 11,
    feature_missing: 21,
    user_interface: 22,
    document: 23,
    uncategory: 99
  }

  enum :defect_origin, {
    defect_origin_unset: 0,
    requirement: 1,
    design: 2,
    coding: 3,
    unit_test: 4,
    integration_test: 5
  }

  enum :activity_type, {
    clear_requirement: 1,
    detail_design: 2,
    code: 3,
    test: 4,
    bug: 5,
    release: 6
  }

  scope :without_parent_tasks, -> { where.not(parent_task_id: nil) }

  delegate :name, to: :owner, prefix: true, allow_nil: true
  delegate :issue_id, :display_childrent?, to: :story, prefix: true, allow_nil: true

  def status_display
    return if status.blank?

    STATUS_DISPLAYS[status]
  end

  def kind_display
    return if kind.blank?

    kind.capitalize
  end
end
