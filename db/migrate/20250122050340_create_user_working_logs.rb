class CreateUserWorkingLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :user_working_logs do |t|
      t.references :user, null: false
      t.float :hours, null: false
      t.integer :activity_type, null: false, default: 0
      t.boolean :standardized, default: false
      t.date :spent_on, null: false
      t.string :activity, null: false
      t.integer :issue_id, null: false
      t.string :project_name, null: false
      t.string :comments
      t.integer :root_issue_id
      t.boolean :owner_issue, default: true

      t.timestamps
    end
  end
end
