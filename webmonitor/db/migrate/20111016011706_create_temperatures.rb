class CreateTemperatures < ActiveRecord::Migration
  def change
    create_table :temperatures do |t|
      t.datetime :checking
      t.float :value

      t.timestamps
    end
  end
end
