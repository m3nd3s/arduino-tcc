class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :by
      t.string :using
      t.integer :interval

      t.timestamps
    end
  end
end
