class AddTokenToSensors < ActiveRecord::Migration
  def change
    add_column :sensors, :token, :string
  end
end
