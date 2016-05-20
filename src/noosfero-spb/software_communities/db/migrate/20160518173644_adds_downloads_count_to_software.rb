class AddsDownloadsCountToSoftware < ActiveRecord::Migration
  def up
    add_column :software_communities_plugin_software_infos, :downloads_count, :integer, :default => 0
  end

  def down
    remove_column :software_communities_plugin_software_infos, :downloads_count
  end
end
