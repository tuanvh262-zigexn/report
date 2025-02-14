class Stories::ShowSupport
  attr_accessor :story

  def initialize story
    @story = story
  end

  def sub_tasks_mapping_activity
    SubTask.activity_types.keys.map do |type|
      {
        type: type,
        tasks: sub_tasks.select{|x| x.try("#{type}?") }
      }
    end.reject {|x| x[:tasks].empty? }
  end

  def timeline_chart
    [
      {
        text: 'Requirement',
        hours: story.requirement_hours,
        start_at: story.requirement_start_at,
        end_at: (story.requirement_end_at.present? && (story.requirement_end_at == story.requirement_start_at)) ? story.requirement_end_at + 1.days : story.requirement_end_at
      },
      {
        text: 'Design',
        hours: story.design_hours,
        start_at: story.design_start_at,
        end_at: (story.design_end_at.present? && (story.design_end_at == story.design_start_at)) ? story.design_end_at + 1.days : story.design_end_at
      },
      {
        text: 'Coding',
        hours: story.coding_hours,
        start_at: story.coding_start_at,
        end_at: (story.coding_start_at.present? && (story.coding_end_at == story.coding_start_at)) ? story.coding_end_at + 1.days : story.coding_end_at
      },
      {
        text: 'Testing',
        hours: story.testing_hours,
        start_at: story.testing_start_at,
        end_at: (story.testing_end_at.present? && (story.testing_end_at == story.testing_start_at)) ? story.testing_end_at + 1.days : story.testing_end_at
      },
      {
        text: 'Bug Fixing',
        hours: story.bug_fixing_hours,
        start_at: story.bug_fixing_start_at,
        end_at: (story.bug_fixing_end_at.present? && (story.bug_fixing_end_at == story.bug_fixing_start_at)) ? story.bug_fixing_end_at + 1.days : story.bug_fixing_end_at
      }
    ].select{|x| x[:start_at].present?}
  end

  def detail_timeline_chart
    [
      {
        text: 'Requirement',
        logs: working_logs.select(&:requirement?).map{|e| {name: e.user_name, hours: e.hours, date: e.spent_on}}
      },
      {
        text: 'Design',
        logs: working_logs.select(&:design?).map{|e| {name: e.user_name, hours: e.hours, date: e.spent_on}}
      },
      {
        text: 'Coding',
        logs: working_logs.select(&:coding?).map{|e| {name: e.user_name, hours: e.hours, date: e.spent_on}}
      },
      {
        text: 'Testing',
        logs: working_logs.select(&:testing?).map{|e| {name: e.user_name, hours: e.hours, date: e.spent_on}}
      },
      {
        text: 'Bug Fixing',
        logs: working_logs.select(&:bug_fixing?).map{|e| {name: e.user_name, hours: e.hours, date: e.spent_on}}
      },
      {
        text: 'Release',
        logs: working_logs.select(&:release?).map{|e| {name: e.user_name, hours: e.hours, date: e.spent_on}}
      },
    ].select{|x| x[:logs].present?}
  end

  private

  def sub_tasks
    @sub_tasks ||= story.sub_tasks.includes(:owner).to_a
  end

  def working_logs
    @working_logs ||= UserWorkingLog.where(root_issue_id: story.issue_id).includes(:user)
  end
end