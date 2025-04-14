class TimecrowdTask < ApplicationRecord
  belongs_to :category, class_name: TimecrowdCategory.name,
    foreign_key: :timecrowd_category_id, primary_key: :timecrowd_id
end
