class RenameCheckingToCheckedAtToTemperatures < ActiveRecord::Migration
  def up
    rename_column :temperatures, :checking, :checked_at
  end

  def down
    rename_column :temperatures, :checked_at, :checking
  end
end
