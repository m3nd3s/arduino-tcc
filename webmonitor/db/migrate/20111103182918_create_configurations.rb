class CreateConfigurations < ActiveRecord::Migration
  def change
    create_table :configurations do |t|
      t.integer :interval
      t.integer :refresh_interval
      t.string :token
      t.float :critical_temperature

      t.timestamps
    end
  end
end
