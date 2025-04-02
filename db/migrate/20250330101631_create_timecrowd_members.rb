class CreateTimecrowdMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :timecrowd_members do |t|
      t.integer :timecrowd_id, null: false
      t.string :nickname
      t.text :avatar_url
      t.boolean :vn_side, default: false

      t.timestamps
    end

    add_index :timecrowd_members, :timecrowd_id, unique: true
  end
end
