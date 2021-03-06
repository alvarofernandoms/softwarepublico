Feature: Institution Field
  As a user
  I want to sign up resgistring my institution
  So others users can use it

  Background:
    Given "GovUserPlugin" plugin is enabled
    And "SoftwareCommunitiesPlugin" plugin is enabled
    And I am logged in as mpog_admin
    And I go to /admin/environment_themes/set/noosfero-spb-theme
    And I go to /admin/plugins
    And I check "GovUserPlugin"
    And I check "SoftwareCommunitiesPlugin"
    And I press "Save changes"
    And Institutions has initial default values on database

  @selenium
  Scenario: Show new institution fields when clicked in create new institution
    Given I follow "Control panel"
    And I follow "Edit Profile"
    When I follow "Create new institution"
    And I should see "New Institution"
    And I should see "Public Institution"
    And I should see "Private Institution"
    And I should see "Corporate Name"
    And I should see "Name"
    And I should see "State"
    And I should see "City"
    And I should see "Country"
    And I should see "CNPJ"
    And I should see "Acronym"
    And I choose "Public Institution"
    Then I should see "Governmental Sphere"
    And I should see "Governmental Power"
    And I should see "Juridical Nature"

  @selenium
  Scenario: Clean state and city values when country is diferent of Brazil
    Given I follow "Control panel"
    And I follow "Edit Profile"
    When I follow "Create new institution"
    And I select "Brazil" from "community_country"
    And I select "Distrito Federal" from "community_state"
    And I fill in "community_city" with "Gama"
    And I select "United States" from "community_country"
    Then I should not see "community_state"
    And I should not see "community_city"
    And I select "Brazil" from "community_country"
    Then I should not see "Gama"

  @selenium
  Scenario: Show sisp and siorg field to admin on create new institution form
    Given I follow "Control panel"
    And I follow "Edit Profile"
    When I follow "Create new institution"
    And I choose "Public Institution"
    Then I should see "SISP?"
    And I should see "SIORG Code"

  @selenium
  Scenario: Not show sisp and siorg field to regular user on create new institution form
    Given the following users
    | login   |
    | zombie  |
    And I am logged in as "zombie"
    When I follow "Control panel"
    And I follow "Edit Profile"
    And I follow "Create new institution"
    And I choose "Public Institution"
    Then I should not see "SISP?"
    And I should not see "SIORG Code"
