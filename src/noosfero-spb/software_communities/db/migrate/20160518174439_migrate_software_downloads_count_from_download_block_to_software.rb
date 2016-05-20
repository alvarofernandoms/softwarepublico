class MigrateSoftwareDownloadsCountFromDownloadBlockToSoftware < ActiveRecord::Migration
  def up
    SoftwareCommunitiesPlugin::SoftwareInfo.find_each do |software|
      software.downloads_count = 0
      blocks = SoftwareCommunitiesPlugin::DownloadBlock.joins(:box).where("boxes.owner_id = #{software.community_id}")
      blocks.each do |b|
        b.downloads.map{ |dl|
          software.downloads_count += dl[:total_downloads] if dl.has_key? :total_downloads
        }
      end
      software.save
    end
  end

  def down
    say "This migration can't be reverted"
  end
end
