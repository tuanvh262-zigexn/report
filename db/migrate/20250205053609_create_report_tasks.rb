class CreateReportTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :report_tasks do |t|
      t.references :team_report, null: false
      t.references :sub_task


      t.timestamps
    end
  end
end
