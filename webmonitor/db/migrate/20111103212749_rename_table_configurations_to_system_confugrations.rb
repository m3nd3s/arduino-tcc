class RenameTableConfigurationsToSystemConfugrations < ActiveRecord::Migration
  def up
    rename_table :configurations, :system_configurations
  end

  def down
    rename_table :system_configurations, :configurations
  end
end
