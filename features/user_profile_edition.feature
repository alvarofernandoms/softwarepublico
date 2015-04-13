Feature: Institution Field
  As a user
  I want to update my update my user data
  So I can maintain my personal data updated

  Background:
    Given "GovUserPlugin" plugin is enabled
    And I am logged in as admin
    And I go to /admin/plugins
    And I check "GovUserPlugin"
    And I press "Save changes"
    And feature "skip_new_user_email_confirmation" is enabled on environment
    And I go to /admin/features/manage_fields
    And I check "person_fields_country_active"
    And I check "person_fields_state_active"
    And I check "person_fields_city_active"
    And I press "Save changes"
    And I am logged in as mpog_admin

  Scenario: Go to control panel when clicked on 'Complete your profile' link
    When I follow "Complete your profile"
    Then I should see "Profile settings for "
    And I should see "Personal information"

  @selenium
  Scenario: Verify text information to use governmental e-mail
    Given I follow "Edit Profile"
    Then I should see "If you work in a public agency use your government e-Mail"

  @selenium
  Scenario: Add more then one instituion on profile editor
    Given I follow "Edit Profile"
    And I follow "Add new institution"
    And I type in "Minis" in autocomplete list "#input_institution" and I choose "Ministerio do Planejamento"
    And I follow "Add new institution"
    And I type in "Gover" in autocomplete list "#input_institution" and I choose "Governo do DF"
    And I follow "Add new institution"
    Then I should see "Ministerio do Planejamento" within ".institutions_added"
    And I should see "Governo do DF" within ".institutions_added"

  @selenium
  Scenario: Verify if field 'city' is shown when Brazil is selected
    Given I follow "Edit Profile"
    Then I should see "City"

  @selenium
  Scenario: Verify if field 'city' does not appear when Brazil is not selected as country
    Given I follow "Edit Profile"
    When I select "United States" from "profile_data_country"
    Then I should not see "City" within ".type-text"

  @selenium
  Scenario: Show message of institution not found
    Given I follow "Edit Profile"
    And I fill in "input_institution" with "Some Nonexistent Institution"
    And I sleep for 1 seconds
    Then I should see "No institution found"
