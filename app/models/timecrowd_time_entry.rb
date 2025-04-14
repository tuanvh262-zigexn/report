class TimecrowdTimeEntry < ApplicationRecord
  belongs_to :member, class_name: TimecrowdMember.name,
    foreign_key: :timecrowd_member_id, primary_key: :timecrowd_id
  belongs_to :task, class_name: TimecrowdTask.name,
    foreign_key: :timecrowd_task_id, primary_key: :timecrowd_id
end
