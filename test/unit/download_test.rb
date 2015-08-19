require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../helpers/plugin_test_helper'

class DownloadTest < ActiveSupport::TestCase
  include PluginTestHelper

  def setup
    @downloads_sample_data = [
      {
        :name=>"Sample data A",
        :link=>"http://some.url.com",
        :software_description=>"all",
        :minimum_requirements=>"none",
        :size=>"10 mb",
        :total_downloads=>0
      },
      {
        :name=>"Sample data B",
        :link=>"http://other.url",
        :software_description=>"Linux",
        :minimum_requirements=>"500 mb Ram",
        :size=>"3 GB",
        :total_downloads=>123
      }
    ]
  end

  should "Set as 0(zero) total_downloads if it is not given" do
    without_total_downloads = Download.new({})
    with_total_downloads = Download.new(@downloads_sample_data.last)

    assert_equal 0, without_total_downloads.total_downloads
    assert_equal @downloads_sample_data.last[:total_downloads], with_total_downloads.total_downloads
  end

  should "Remove downloads without a name" do
    @downloads_sample_data[1] = @downloads_sample_data[1].slice! :name
    downloads = Download.validate_download_list @downloads_sample_data

    assert_equal 1, downloads.size
    assert_equal @downloads_sample_data[0][:name], downloads[0][:name]
  end

  should "Only set total_downloads if the value is integer" do
    download = Download.new(@downloads_sample_data.last)

    download.total_downloads = "456"
    assert_not_equal 456, download.total_downloads

    download.total_downloads = 456
    assert_equal 456, download.total_downloads
  end
end
