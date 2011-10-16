class CreateSensors < ActiveRecord::Migration
  def change
    create_table :sensors do |t|
      t.integer :sid
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
