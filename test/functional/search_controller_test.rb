require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../helpers/plugin_test_helper'
require(
  File.dirname(__FILE__) +
  '/../../../../app/controllers/public/search_controller'
)

class SearchController; def rescue_action(e) raise e end; end

class SearchControllerTest < ActionController::TestCase
  include PluginTestHelper

  def setup
    @environment = Environment.default
    @environment.enabled_plugins = ['MpogSoftwarePlugin']
    @environment.save

    @controller = SearchController.new
    @request = ActionController::TestRequest.new
    @request.stubs(:ssl?).returns(:false)
    @response = ActionController::TestResponse.new

    create_software_categories
  end

  should "communities searches don't have software or institution" do
    community = create_community("New Community")
    software = create_software_info("New Software")
    institution = create_private_institution(
      "New Private Institution",
      "NPI" ,
      "Brazil",
      "DF",
      "Gama",
      "66.544.314/0001-63"
      )

    get :communities, :query => "New"

    assert_includes assigns(:searches)[:communities][:results], community
    assert_not_includes assigns(:searches)[:communities][:results], software
    assert_not_includes assigns(:searches)[:communities][:results], institution
  end

  should "software_infos search don't have community or institution" do
     community = create_community("New Community")
     software = create_software_info("New Software")
     institution = create_private_institution("New Private Institution", "NPI" , "Brazil", "DF", "Gama", "66.544.314/0001-63")

     software.license_info = LicenseInfo.create :version=>"GPL - 1.0"
     software.save!

     get :software_infos, :query => "New"

     assert_includes assigns(:searches)[:software_infos][:results], software.community
     assert_not_includes assigns(:searches)[:software_infos][:results], community
     assert_not_includes assigns(:searches)[:software_infos][:results], institution.community
  end


  should "Don't found template in communities search" do
    community = create_community("New Community")
    software = create_software_info("New Software")
    software.license_info = LicenseInfo.create(:version => "GPL")
    software.save!

    institution = create_private_institution(
      "New Private Institution",
      "NPI" ,
      "Brazil",
      "DF",
      "Gama",
      "66.544.314/0001-63"
    )

    community_template = create_community("New Community Template")
    community_template.is_template = true
    community_template.save!

    get :communities, :query => "New"

    assert_not_includes(
      assigns(:searches)[:communities][:results],
      community_template
    )
  end

  should "institutions_search don't have community or software" do
    community = create_community("New Community")
    software = create_software_info("New Software")
    institution = create_private_institution(
      "New Private Institution",
      "NPI" ,
      "Brazil",
      "DF",
      "Gama",
      "66.544.314/0001-63"
    )

    get :institutions, :query => "New"

    assert_includes(
      assigns(:searches)[:institutions][:results],
      institution.community
    )
    assert_not_includes assigns(:searches)[:institutions][:results], community
    assert_not_includes(
      assigns(:searches)[:institutions][:results],
      software.community
    )
  end

  should "software_infos search by category" do
    software_one = create_software_info("Software One")
    software_two = create_software_info("Software Two")

    software_one.community.categories << Category.first
    software_two.community.categories << Category.last

    software_one.license_info = LicenseInfo.create :version=>"GPL - 1.0"
    software_two.license_info = LicenseInfo.create :version=>"GPL - 1.0"

    software_one.save!
    software_two.save!

    get(
      :software_infos,
      :query => "",
      :selected_categories => [Category.first.id]
    )

    assert_includes assigns(:searches)[:software_infos][:results], software_one.community
    assert_not_includes assigns(:searches)[:software_infos][:results], software_two.community
  end

  should "software_infos search by programming language" do
    software_one = create_software_info("Software One")
    software_two = create_software_info("Software Two")

    software_one.license_info = LicenseInfo.create :version=>"GPL - 1.0"
    software_two.license_info = LicenseInfo.create :version=>"GPL - 1.0"

    software_one.software_languages << create_software_language("Python", "1.0")
    software_two.software_languages << create_software_language("Java", "8.1")

    software_one.save!
    software_two.save!

    get(
      :software_infos,
      :query => "python",
    )

    assert_includes assigns(:searches)[:software_infos][:results], software_one.community
    assert_not_includes assigns(:searches)[:software_infos][:results], software_two.community
  end

  should "software_infos search by database description" do
    software_one = create_software_info("Software One")
    software_two = create_software_info("Software Two")

    software_one.license_info = LicenseInfo.create :version=>"GPL - 1.0"
    software_two.license_info = LicenseInfo.create :version=>"GPL - 1.0"

    software_one.software_databases << create_software_database("MySQL", "1.0")
    software_two.software_databases << create_software_database("Postgrees", "8.1")

    software_one.save!
    software_two.save!

    get(
      :software_infos,
      :query => "mysql",
    )

    assert_includes assigns(:searches)[:software_infos][:results], software_one.community
    assert_not_includes assigns(:searches)[:software_infos][:results], software_two.community
  end

  should "software_infos search by finality" do
    software_one = create_software_info("Software One", :finality => "Help")
    software_two = create_software_info("Software Two", :finality => "Task")

    software_one.license_info = LicenseInfo.create :version=>"GPL - 1.0"
    software_two.license_info = LicenseInfo.create :version=>"GPL - 1.0"

    software_one.save!
    software_two.save!

    get(
      :software_infos,
      :query => "help",
    )

    assert_includes assigns(:searches)[:software_infos][:results], software_one.community
    assert_not_includes assigns(:searches)[:software_infos][:results], software_two.community
  end

  should "software_infos search by acronym" do
    software_one = create_software_info("Software One", :acronym => "SFO", :finality => "Help")
    software_two = create_software_info("Software Two", :acronym => "SFT", :finality => "Task")

    software_one.license_info = LicenseInfo.create :version=>"GPL - 1.0"
    software_two.license_info = LicenseInfo.create :version=>"GPL - 1.0"

    software_one.save!
    software_two.save!

    get(
      :software_infos,
      :query => "SFO",
    )

    assert_includes assigns(:searches)[:software_infos][:results], software_one.community
    assert_not_includes assigns(:searches)[:software_infos][:results], software_two.community
  end

  private

  def create_software_categories
    category_software = Category.create!(
      :name => "Software",
      :environment => @environment
    )
    Category.create(
      :name => "Category One",
      :environment => @environment,
      :parent => category_software
    )
    Category.create(
      :name => "Category Two",
      :environment => @environment,
      :parent => category_software
    )
  end

  def create_software_language(name, version)
    unless ProgrammingLanguage.find_by_name(name)
      ProgrammingLanguage.create(:name => name)
    end

    software_language = SoftwareLanguage.new
    software_language.programming_language = ProgrammingLanguage.find_by_name(name)
    software_language.version = version
    software_language.save!

    software_language
  end

  def create_software_database(name, version)
    unless DatabaseDescription.find_by_name(name)
      DatabaseDescription.create(:name => name)
    end

    software_database = SoftwareDatabase.new
    software_database.database_description = DatabaseDescription.find_by_name(name)
    software_database.version = version
    software_database.save!

    software_database
  end


end
