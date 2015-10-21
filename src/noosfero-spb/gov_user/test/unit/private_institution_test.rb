require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../helpers/plugin_test_helper'

class PrivateInstitutionTest < ActiveSupport::TestCase
  include PluginTestHelper
  def setup
    @institution = create_private_institution(
                      "Simple Private Institution",
                      "SPI",
                      "BR",
                      "DF",
                      "Gama",
                      "00.000.000/0001-00"
                    )
  end

  def teardown
    @institution = nil
    Institution.destroy_all
  end

  should "save without a cnpj" do
    @institution.cnpj = nil

    assert @institution.save
  end

  should "save without fantasy name" do
    @institution.acronym = nil
    @institution.community.save

    assert @institution.save
  end
end