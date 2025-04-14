class CreateTimecrowdTask < ActiveRecord::Migration[8.0]
  def change
    create_table :timecrowd_tasks do |t|
      t.integer :timecrowd_id, null: false
      t.references :timecrowd_category
      t.text :title

      t.timestamps
    end

    add_index :timecrowd_tasks, :timecrowd_id, unique: true
  end
end
