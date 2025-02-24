class CreateStories < ActiveRecord::Migration[8.0]
  def change
    create_table :stories do |t|
      t.references :user
      t.integer :issue_id
      t.integer :status, null: false, default: 0
      t.integer :level
      t.string :subject
      t.date :start_date
      t.date :due_date
      t.decimal :time_estimate_ratio, :scale => 2, :precision => 10
      t.decimal :total_estimated_hours, :scale => 2, :precision => 10
      t.decimal :total_spent_hours, :scale => 2, :precision => 10
      t.integer :test_case_count, default: 0
      t.integer :bug_count, default: 0
      t.integer :prod_bug_count, default: 0
      t.integer :done_ratio, default: 0
      t.integer :timecrowd_est_ratio, default: 0
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
      t.decimal :requirement_hours, :scale => 2, :precision => 10
      t.decimal :design_hours, :scale => 2, :precision => 10
      t.decimal :coding_hours, :scale => 2, :precision => 10
      t.decimal :testing_hours, :scale => 2, :precision => 10
      t.decimal :bug_fixing_hours, :scale => 2, :precision => 10
      t.decimal :release_hours, :scale => 2, :precision => 10
      t.decimal :cross_support_hours, :scale => 2, :precision => 10
      t.decimal :time_crowd_est_hours, :scale => 2, :precision => 10
      t.date :finished_at
      t.date :redmine_created_at
      t.date :redmine_updated_at

      t.timestamps
    end

    add_index :stories, :issue_id, unique: true
  end
end
