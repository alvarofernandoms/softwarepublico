require File.dirname(__FILE__) + '/../../../../test/test_helper'

OperatingSystemName.create(:name=>"Debina")
OperatingSystemName.create(:name=>"Fedora")
OperatingSystemName.create(:name=>"CentOS")

class OperatingSystemHelperTest < ActiveSupport::TestCase

  def setup
    @operating_system_objects = [
      {:operating_system_name_id => "1" ,:version => "2.0"},
      {:operating_system_name_id => "2" ,"version" => "2.1"},
      {:operating_system_name_id => "3" ,"version" => "2.2"}
    ]
    @operating_system_objects
  end

  def teardown
    @operating_system_objects = nil
  end

  should "return an empty list" do
    empty_list = []
    assert_equal  [],OperatingSystemHelper.list_operating_system(empty_list)
  end

  should "return a list with current OperatingSystems" do
    list_compare = []
    list_op = OperatingSystemHelper.list_operating_system(@operating_system_objects)
    assert_equal  list_compare.class, list_op.class
  end

  should "have same information from the list passed as parameter" do
    list_compare = OperatingSystemHelper.list_operating_system(@operating_system_objects)
    first_operating = @operating_system_objects.first[:operating_system_name_id]
    assert_equal first_operating, list_compare.first.operating_system_name_id.to_s
  end

  should "return a list with the same size of the parameter" do
    list_compare = OperatingSystemHelper.list_operating_system(@operating_system_objects)
    assert_equal @operating_system_objects.count, list_compare.count
  end

  should "return false if list_operating_system are empty or null" do
    list_compare = []
    assert_equal false,OperatingSystemHelper.valid_list_operating_system?(list_compare)
  end

  should "return a html text with operating system" do
      operating_systems = []

      operating_system = OperatingSystemName.new
      operating_system.name = "teste"

      software_operating_system = OperatingSystem.new
      software_operating_system.version = 2
      software_operating_system.operating_system_name = operating_system

      operating_systems << software_operating_system
      op_table = OperatingSystemHelper.operating_system_as_tables(operating_systems)

      assert_not_nil op_table.first.call.index(OperatingSystemName.first.name)
  end
end
