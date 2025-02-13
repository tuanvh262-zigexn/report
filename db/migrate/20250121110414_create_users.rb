class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.integer :redmine_id
      t.integer :role
      t.boolean :actived
      t.boolean :part_time, default: false
      t.float :buffer_rate

      t.timestamps
    end

    add_index :users, :redmine_id, unique: true
  end
end
