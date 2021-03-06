require 'test_helper'

class DatabaseValidationTest < ActiveSupport::TestCase

  def setup
   @database_desc = SoftwareCommunitiesPlugin::DatabaseDescription.create(:name => "ABC")
   @database = SoftwareCommunitiesPlugin::SoftwareDatabase.new
   @database.database_description = @database_desc
   @database.version = "MYSQL"
   @database
  end

  def teardown
    @database = nil
    SoftwareCommunitiesPlugin::DatabaseDescription.destroy_all
    SoftwareCommunitiesPlugin::SoftwareDatabase.destroy_all
  end

  should "Save database if all fields are filled" do
    assert_equal true, @database.save
  end

  should "not save database if database_description is empty" do
    @database.database_description = nil
    assert_equal true, !@database.save
  end

  should "not save database if version are empty" do
    @database.version = " "
    assert_equal true, !@database.save
  end

  should "not save database if version is too long" do
    @database.version = "A too long version to be a valid version for database"
    assert !@database.save
  end
end
