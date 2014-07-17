require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../controllers/mpog_software_plugin_controller'

class MpogSoftwarePluginController; def rescue_action(e) raise e end; end


class MpogSoftwarePluginControllerTest < ActionController::TestCase

  def setup
    @govPower = GovernmentalPower.create(:name=>"Some Gov Power")
    @govSphere = GovernmentalSphere.create(:name=>"Some Gov Sphere")
    @response = ActionController::TestResponse.new
    @institution_list = []
    @institution_list << create_public_institution("Ministerio Publico da Uniao", "MPU", @govPower, @govSphere)
    @institution_list << create_public_institution("Tribunal Regional da Uniao", "TRU", @govPower, @govSphere)
  end

  should "Search for institution with acronym" do
    xhr :get, :get_institutions, :query=>"TRU"

    json_response = ActiveSupport::JSON.decode(@response.body)

    assert_equal "Tribunal Regional da Uniao", json_response[0]["value"]
  end

  should "Search for institution with name" do
    xhr :get, :get_institutions, :query=>"Minis"

    json_response = ActiveSupport::JSON.decode(@response.body)

    assert_equal "Ministerio Publico da Uniao", json_response[0]["value"]
  end

  should "search with name or acronym and return a list with institutions" do
    xhr :get, :get_institutions, :query=>"uni"

    json_response = ActiveSupport::JSON.decode(@response.body)

    assert_equal "Ministerio Publico da Uniao", json_response[0]["value"]
    assert_equal "Tribunal Regional da Uniao", json_response[1]["value"]
  end

  should "method create_institution return the html for modal" do
    xhr :get, :create_institution
    assert_template 'create_institution'
  end

  should "create new institution with ajax" do
    @controller.stubs(:verify_recaptcha).returns(true)

    xhr :get, :new_institution,
      :authenticity_token=>"dsa45a6das52sd",
      :community=>{:name=>"foo bar"},
      :institution => {:cnpj=>"12.234.567/8900-10", :acronym=>"fb", :type=>"PublicInstitution"},
      :governmental=>{:power=>@govPower.id, :sphere=>@govSphere.id},
      :recaptcha_response_field=>''

    json_response = ActiveSupport::JSON.decode(@response.body)

    assert json_response["success"]
  end

  should "not create a institution that already exists" do
    @controller.stubs(:verify_recaptcha).returns(true)

    xhr :get, :new_institution,
      :authenticity_token=>"dsa45a6das52sd",
      :community=>{:name=>"Ministerio Publico da Uniao"},
      :institution => {:cnpj=>"12.234.567/8900-10", :acronym=>"fb", :type=>"PublicInstitution"},
      :governmental=>{:power=>@govPower.id, :sphere=>@govSphere.id},
      :recaptcha_response_field=>''

    json_response = ActiveSupport::JSON.decode(@response.body)

    assert !json_response["success"]
  end

  should "verify if institution name already exists" do
    xhr :get, :institution_already_exists, :name=>"Ministerio Publico da Uniao"
    assert_equal "true", @response.body

    xhr :get, :institution_already_exists, :name=>"Another name here"
    assert_equal "false", @response.body
  end


  should "response as XML to export softwares" do
    get :download, :format => 'xml'
    assert_equal 'text/xml', @response.content_type
  end

  should "response as CSV to export softwares" do
    get :download, :format => 'csv'
    assert_equal 'text/csv', @response.content_type
    assert_equal "name;acronym;demonstration_url;e_arq;e_mag;e_ping;features;icp_brasil;objectives;operating_platform\n", @response.body
  end


  private

  def create_public_institution name, acronym, gov_p, gov_s
    institution_community = Community::new :name=>name
    institution = PublicInstitution.new
    institution.community = institution_community
    institution.name = name
    institution.acronym  = acronym
    institution.governmental_power = gov_p
    institution.governmental_sphere = gov_s
    institution.save
    institution
  end
end
