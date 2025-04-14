class CreateTimecrowdTimeEntry < ActiveRecord::Migration[8.0]
  def change
    create_table :timecrowd_time_entries do |t|
      t.integer :timecrowd_id, null: false
      t.references :timecrowd_member, null: false
      t.references :timecrowd_task
      t.integer :duration
      t.boolean :vn_side, default: false
      t.date :spent_on, null: false

      t.timestamps
    end

    add_index :timecrowd_time_entries, :timecrowd_id, unique: true
  end
end
