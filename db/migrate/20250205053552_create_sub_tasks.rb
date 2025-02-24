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
      t.integer :done_ratio, default: 0
      t.decimal :time_estimate_ratio, :scale => 2, :precision => 10
      t.decimal :total_estimated_hours, :scale => 2, :precision => 10
      t.decimal :total_spent_hours, :scale => 2, :precision => 10
      t.boolean :is_bug
      t.integer :bug_category, default: 0
      t.integer :defect_origin, default: 0
      t.boolean :meet_deadline, default: false
      t.boolean :update_title, default: false
      t.integer :activity_type
      t.date :redmine_created_at
      t.date :redmine_updated_at

      t.timestamps
    end

    add_index :sub_tasks, :issue_id, unique: true
  end
end
