class TeamReport < ApplicationRecord
  has_many :report_tasks
  has_many :tasks, class_name: SubTask.name, through: :report_tasks, source: :sub_task
  has_many :stories, class_name: Story.name, through: :tasks, source: :story

  def end_date
    start_date.send(time_period)
  end
end
