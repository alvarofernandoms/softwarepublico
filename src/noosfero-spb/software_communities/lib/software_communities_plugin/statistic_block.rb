class SoftwareCommunitiesPlugin::StatisticBlock < Block

  settings_items :benefited_people, :type => :integer, :default => 0
  settings_items :saved_resources, :type => :float, :default => 0.0

  attr_accessible :benefited_people, :saved_resources

  def self.description
    _('Software Statistics')
  end

  def help
    _('This block displays software statistics.')
  end

  def content(args={})
    block = self
    statistics = get_software_statistics

    lambda do |object|
      render(
        :file => 'blocks/software_statistics',
        :locals => {
          :block => block,
          :statistics => statistics
        }
      )
    end
  end

  def cacheable?
    false
  end

  private

  def get_profile_download_blocks profile
    SoftwareCommunitiesPlugin::DownloadBlock.joins(:box).where("boxes.owner_id = ?", profile.id)
  end

  def get_software_statistics
    statistics = {}
    software = SoftwareCommunitiesPlugin::SoftwareInfo.find_by_community_id(self.owner.id)
    if software.present?
      statistics[:saved_resources] = software.saved_resources
      statistics[:benefited_people] = software.benefited_people
      statistics[:downloads_count] = software.downloads_count
    else
      statistics[:saved_resources] = 0
      statistics[:benefited_people] = 0
      statistics[:downloads_count] = 0
    end
    statistics
  end
end
