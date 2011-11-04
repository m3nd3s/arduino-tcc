class RemoveTokenFromSystemConfigurations < ActiveRecord::Migration
  def up
    remove_column :system_configurations, :token
  end

  def down
    add_column :system_configurations, :token, :string
  end
end
