class AddSensorIdToTemperatures < ActiveRecord::Migration
  def change
    add_column :temperatures, :sensor_id, :integer
  end
end
