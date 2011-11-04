class AddSomeColumnsToSensors < ActiveRecord::Migration
  def up
    add_column :sensors, :max_temperature, :float
    add_column :sensors, :min_temperature, :float
    add_column :sensors, :alert, :boolean
  end

  def down
    remove_column :sensors, :max_temperature
    remove_column :sensors, :min_temperature
    remove_column :sensors, :alert
  end
end
