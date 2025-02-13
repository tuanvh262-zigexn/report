class CreateStories < ActiveRecord::Migration[8.0]
  def change
    create_table :stories do |t|
      t.references :user
      t.integer :issue_id
      t.integer :status, null: false, default: 0
      t.integer :level
      t.string :subject
      t.string :link_issue
      t.date :start_date
      t.date :due_date
      t.float :time_estimate_ratio
      t.float :total_estimated_hours
      t.float :total_spent_hours
      t.integer :test_case_count, default: 0
      t.integer :bug_count, default: 0
      t.integer :prod_bug_count, default: 0
      t.date :requirement_start_at
      t.date :requirement_end_at
      t.date :design_start_at
      t.date :design_end_at
      t.date :coding_start_at
      t.date :coding_end_at
      t.date :testing_start_at
      t.date :testing_end_at
      t.date :bug_fixing_start_at
      t.date :bug_fixing_end_at
      t.float :requirement_hours
      t.float :design_hours
      t.float :coding_hours
      t.float :testing_hours
      t.float :bug_fixing_hours
      t.float :release_hours
      t.float :cross_support_hours
      t.date :finished_at

      t.timestamps
    end

    add_index :stories, :issue_id, unique: true
  end
end
