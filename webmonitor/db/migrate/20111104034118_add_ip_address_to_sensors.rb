class AddIpAddressToSensors < ActiveRecord::Migration
  def change
    add_column :sensors, :ip_address, :string
  end
end
