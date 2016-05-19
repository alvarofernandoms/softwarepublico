class ChangeSiorgColumnType < ActiveRecord::Migration
  def self.up
    change_column :institutions, :siorg_code, :string
  end

  def self.down
    change_column :institutions, :siorg_code, :integer
  end
end
