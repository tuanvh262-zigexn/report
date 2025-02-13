class CreateSubTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :sub_tasks do |t|
      t.references :story
      t.references :owner
      t.integer :issue_id
      t.integer :status, null: false, default: 0
      t.string :kind, null: false
      t.string :subject
      t.date :start_date
      t.date :due_date
      t.float :time_estimate_ratio
      t.float :total_estimated_hours
      t.float :total_spent_hours
      t.boolean :is_bug
      t.integer :bug_category, default: 0
      t.integer :defect_origin, default: 0
      t.string :cause_analyze
      t.boolean :meet_deadline, default: false
      t.integer :activity_type

      t.timestamps
    end

    add_index :sub_tasks, :issue_id, unique: true
  end
end
