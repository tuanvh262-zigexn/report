class CreateTeamReports < ActiveRecord::Migration[8.0]
  def change
    create_table :team_reports do |t|
      t.references :user
      t.string :type, null: false
      t.json :content, null: false
      t.date :start_date, null: false
      t.boolean :latest, default: false
      t.boolean :public, default: false
      t.decimal :total_time_working, default: 0, :scale => 2, :precision => 10

      t.timestamps
    end

    add_index :team_reports, [:type, :user_id, :start_date], unique: true
  end
end
