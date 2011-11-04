class RenameCriticalTemperatureToCriticalLevelToSystemConfigurations < ActiveRecord::Migration
  def up
    rename_column :system_configurations, :critical_temperature, :critical_level
  end

  def down
    rename_column :system_configurations, :critical_level, :critical_temperature
  end
end
