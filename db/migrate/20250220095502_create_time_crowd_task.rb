class CreateTimeCrowdTask < ActiveRecord::Migration[8.0]
  def change
    create_table :time_crowd_tasks do |t|
      t.references :story
      t.integer :time_crowd_id
      t.integer :activity_type
      t.string :total_time
      t.integer :total_second
      t.json :content, null: false

      t.timestamps
    end

    add_index :time_crowd_tasks, [:activity_type, :story_id, :time_crowd_id], unique: true
  end
end
