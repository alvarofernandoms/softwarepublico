require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../helpers/plugin_test_helper'

class SoftwareInfoValidationTest < ActiveSupport::TestCase

  include PluginTestHelper

  should "Return original license_info when license is not 'Another'" do
    @software_info = create_software_info("software_test")
    @license_info = create_license_info("license_test")

    @software_info.license_info = @license_info
    @software_info.save!

    assert_equal @software_info.license_info, @license_info
  end

  should "Return license_info with nil id when license is 'Another'" do
    @software_info = create_software_info("software_test")
    @license_another = create_license_info("Another")

    @software_info.license_info = @license_another
    @software_info.save!

    assert_equal @software_info.license_info_id, @license_another.id
    assert_equal @software_info.license_info.id, nil
  end

  should "Return fake license_info when call method another_license" do
    @software_info = create_software_info("software_test")
    @license_another = create_license_info("Another")

    another_license_version = "Another Version"
    another_license_link = "#another_link"

    @software_info.another_license(another_license_version, another_license_link)

    assert_equal @software_info.license_info_id, @license_another.id
    assert_equal @software_info.license_info.id, nil
    assert_equal @software_info.license_info.version, another_license_version
    assert_equal @software_info.license_info.link, another_license_link
  end

end