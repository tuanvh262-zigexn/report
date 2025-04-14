class CreateTimecrowdCategory < ActiveRecord::Migration[8.0]
  def change
    create_table :timecrowd_categories do |t|
      t.integer :timecrowd_id, null: false
      t.text :title

      t.timestamps
    end

    add_index :timecrowd_categories, :timecrowd_id, unique: true
  end
end
