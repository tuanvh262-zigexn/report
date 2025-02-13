class ReportTask < ApplicationRecord
  belongs_to :team_report
  belongs_to :sub_task, optional: true
end
