Feature: User Registration

  Background:
    Given "MpogSoftwarePlugin" plugin is enabled
    And I am logged in as admin
    And I go to /admin/plugins
    And I check "MpogSoftwarePlugin"
    And I press "Save changes"
    And I go to /admin/features/manage_fields
    And I check "person_fields_country_active"
    And I check "person_fields_country_required"
    And I check "person_fields_country_signup"
    And I check "person_fields_state_active"
    And I check "person_fields_state_required"
    And I check "person_fields_state_signup"
    And I check "person_fields_city_active"
    And I check "person_fields_city_required"
    And I check "person_fields_city_signup"
    And I press "Save changes"
    And the following blocks
      | owner       | type       |
      | environment | LoginBlock |
    And I go to /account/logout

  @selenium
  Scenario: Successfull registration with only required fields
    Given I go to /account/signup
    And I fill in the following within ".no-boxes":
      | e-Mail                | josesilva@example.com  |
      | Username              | josesilva              |
      | Password              | secret                 |
      | Password confirmation | secret                 |
      | Full name             | José da Silva          |
      | State                 | Bahia                  |
      | City                  | Salvador               |
    And I select "Brazil" from "profile_data[country]"
    And wait for the captcha signup time
    And I press "Create my account"
    When José da Silva's account is activated
    And I go to login page
    And I fill in "Username" with "josesilva"
    And I fill in "Password" with "secret"
    And I press "Log in"
    Then I should be logged in as "josesilva"

  @selenium
  Scenario: Successfull registration with governmental e-mail typing the name of the organization
    Given I go to /account/signup
    And Institutions has initial default values on database
    And the following public institutions
      | name                       | acronym | cnpj               | governmental_power | governmental_sphere |
      | Ministerio das Cidades     | MC      | 58.745.189/0001-21 | Executivo          | Federal             |
      | Governo do DF              | GDF     | 12.645.166/0001-44 | Legislativo        | Federal             |
      | Ministerio do Planejamento | MP      | 41.769.591/0001-43 | Judiciario         | Federal             |
    And I fill in the following within ".no-boxes":
      | e-Mail                | josesilva@serpro.gov.br|
      | Username              | josesilva              |
      | Password              | secret                 |
      | Password confirmation | secret                 |
      | Full name             | José da Silva          |
      | State                 | Bahia                  |
      | City                  | Salvador               |
      | Secondary e-Mail      | josesilva@example.com  |
      | Role                  | TI analist             |
    And I select "Brazil" from "profile_data[country]"
    And I type in "Minis" into autocomplete list "input_institution" and I choose "Ministerio do Planejamento"
    And wait for the captcha signup time
    And I press "Create my account"
    When José da Silva's account is activated
    And I go to login page
    And I fill in "Username" with "josesilva"
    And I fill in "Password" with "secret"
    And I press "Log in"
    Then I should be logged in as "josesilva"

  @selenium
  Scenario: Successfull registration with governmental e-mail typing the acronym of the organization
    Given I go to /account/signup
    And Institutions has initial default values on database
    And the following public institutions
      | name                       | acronym | cnpj               | governmental_power | governmental_sphere |
      | Ministerio das Cidades     | MC      | 58.745.189/0001-21 | Executivo          | Federal             |
      | Governo do DF              | GDF     | 12.645.166/0001-44 | Legislativo        | Federal             |
      | Ministerio do Planejamento | MP      | 41.769.591/0001-43 | Judiciario         | Federal             |
    And I fill in the following within ".no-boxes":
      | e-Mail                | josesilva@serpro.gov.br|
      | Username              | josesilva              |
      | Password              | secret                 |
      | Password confirmation | secret                 |
      | Full name             | José da Silva          |
      | State                 | Bahia                  |
      | City                  | Salvador               |
      | Secondary e-Mail      | josesilva@example.com  |
      | Role                  | TI analist             |
    And I select "Brazil" from "profile_data[country]"
    And I type in "MP" into autocomplete list "input_institution" and I choose "Ministerio do Planejamento"
    And wait for the captcha signup time
    And I press "Create my account"
    When José da Silva's account is activated
    And I go to login page
    And I fill in "Username" with "josesilva"
    And I fill in "Password" with "secret"
    And I press "Log in"
    Then I should be logged in as "josesilva"

  @selenium
  Scenario: Unsuccessfull registration due to the existance of e-mail as secondary another user's e-mail
    Given the following users
      | login | name        | email             | country | state | city     |
      | maria | Maria Silva | maria@example.com | Brazil  | DF    | Brasilia |
    And the user "maria" has "user@example.com" as secondary e-mail
    And I go to /account/signup
    And I fill in the following within ".no-boxes":
      | e-Mail                | user@example.com       |
      | Username              | josesilva              |
      | Password              | secret                 |
      | Password confirmation | secret                 |
      | Full name             | José da Silva          |
      | State                 | Bahia                  |
      | City                  | Salvador               |
    And wait for the captcha signup time
    And I select "Brazil" from "profile_data[country]"
    When I press "Create my account"
    Then I should see "E-mail or secondary e-mail already taken."

  @selenium
  Scenario: Unsuccessfull registration due to the existance of secondary e-mail as another user's secondary e-mail
    Given the following users
      | login | name        | email             | country | state | city     |
      | maria | Maria Silva | maria@example.com | Brazil  | DF    | Brasilia |
    And the user "maria" has "user@example.com" as secondary e-mail
    And I go to /account/signup
    And I fill in the following within ".no-boxes":
      | e-Mail                | josesilva@example.com  |
      | Username              | josesilva              |
      | Password              | secret                 |
      | Password confirmation | secret                 |
      | Full name             | José da Silva          |
      | State                 | Bahia                  |
      | City                  | Salvador               |
      | Secondary e-Mail      | user@example.com       |
    And I select "Brazil" from "profile_data[country]"
    And wait for the captcha signup time
    When I press "Create my account"
    Then I should see "E-mail or secondary e-mail already taken."

  @selenium
  Scenario: Unsuccessfull registration due to the existance of secondary e-mail as another user's e-mail
    Given the following users
      | login | name        | email             | country | state | city     |
      | maria | Maria Silva | user@example.com | Brazil  | DF    | Brasilia |
    And I go to /account/signup
    And I fill in the following within ".no-boxes":
      | e-Mail                | josesilva@example.com  |
      | Username              | josesilva              |
      | Password              | secret                 |
      | Password confirmation | secret                 |
      | Full name             | José da Silva          |
      | State                 | Bahia                  |
      | City                  | Salvador               |
      | Secondary e-Mail      | user@example.com       |
    And I select "Brazil" from "profile_data[country]"
    And wait for the captcha signup time
    When I press "Create my account"
    Then I should see "E-mail or secondary e-mail already taken."

  @selenium
  Scenario: Unsuccessfull registration due to both primary e-mail and secondary e-mail being equal
    Given I go to /account/signup
    And I fill in the following within ".no-boxes":
      | Username              | josesilva              |
      | e-Mail                | josesilva@example.com  |
      | Password              | secret                 |
      | Password confirmation | secret                 |
      | Full name             | José da Silva          |
      | State                 | Bahia                  |
      | City                  | Salvador               |
      | Secondary e-Mail      | josesilva@example.com  |
    And I select "Brazil" from "profile_data[country]"
    And wait for the captcha signup time
    When I press "Create my account"
    Then I should see "Email must be different from secondary email."

  @selenium
  Scenario: Unsuccessfull registration due to government fields being blank
    Given I go to /account/signup
    And I fill in the following within ".no-boxes":
      | Username              | josesilva              |
      | e-Mail                | josesilva@serpro.gov.br|
      | Password              | secret                 |
      | Password confirmation | secret                 |
      | Full name             | José da Silva          |
      | Secondary e-Mail      | josesilva@example.com  |
    And I select "Brazil" from "profile_data[country]"
    And wait for the captcha signup time
    When I press "Create my account"
    Then I should see "Role can't be blank if e-mail has governamental sulfixes."
    And I should see "Institution is obligatory if user has a government email."
    And I should see "State can't be blank"
    And I should see "City can't be blank"

  @selenium
  Scenario: Unsuccessfull registration due to secondary email is governmental and primary is not
    Given I go to /account/signup
    And I fill in the following within ".no-boxes":
      | Username              | josesilva              |
      | e-Mail                | josesilva@example.com  |
      | Password              | secret                 |
      | Password confirmation | secret                 |
      | Full name             | José da Silva          |
      | State                 | Bahia                  |
      | City                  | Salvador               |
      | Secondary e-Mail      | josesilva@serpro.gov.br|
    And wait for the captcha signup time
    When I press "Create my account"
    Then I should see "The governamental email must be the primary one."

  @selenium-fixme
  Scenario: Show incomplete resgistration percentage
    Given I go to /account/signup
    And I fill in the following within ".no-boxes":
      | e-Mail                | josesilva@gmail.com    |
      | Password              | secret                 |
      | Password confirmation | secret                 |
      | Full name             | José da Silva          |
      | State                 | Bahia                  |
      | City                  | Salvador               |
      | Secondary e-Mail      | josesilva@example.com  |
      | Role                  | TI analist             |
    And I select "Brazil" from "profile_data[country]"
    And I fill in "Username" with "josesilva"
    And wait for the captcha signup time
    And I press "Create my account"
    When José da Silva's account is activated
    And I go to login page
    And I fill in "Username" with "josesilva"
    And I fill in "Password" with "secret"
    And I press "Log in"
    Then I should see "Percentage incomplete: 63 %"

  @selenium
  Scenario: Remove the incomplete resgistration percentage message
    Given I go to /account/signup
    And I fill in the following within ".no-boxes":
      | e-Mail                | josesilva@gmail.com    |
      | Password              | secret                 |
      | Password confirmation | secret                 |
      | Full name             | José da Silva          |
      | State                 | Bahia                  |
      | City                  | Salvador               |
      | Secondary e-Mail      | josesilva@example.com  |
      | Role                  | TI analist             |
    And I select "Brazil" from "profile_data[country]"
    And I fill in "Username" with "josesilva"
    And wait for the captcha signup time
    And I press "Create my account"
    When José da Silva's account is activated
    And I go to login page
    And I fill in "Username" with "josesilva"
    And I fill in "Password" with "secret"
    And I press "Log in"
    And I click on anything with selector ".hide-incomplete-percentage"
    Then I should not see "Percentage incomplete: 63 %"

  @selenium
  Scenario: When the user log out and log in again, the percentage registration message must appear
    Given the following users
      | login | name        | email             | country | state | city     |
      | maria | Maria Silva | maria@example.com | Brazil  | DF    | Brasilia |
    When I am logged in as "maria"
    And I follow "Logout"
    And I am logged in as "maria"
    Then I should see "Percentage incomplete:"

  @selenium
  Scenario: When the user logged in and hide link of imcomplete percentage and user log out and log in again, the percentage registration link must appear
    Given the following users
      | login | name        | email             | country | state | city     |
      | maria | Maria Silva | maria@example.com | Brazil  | DF    | Brasilia |
    When I am logged in as "maria"
    And I go to /profile/maria
    And I should see "Percentage incomplete:"
    And I click on anything with selector ".hide-incomplete-percentage"
    And I follow "Logout"
    And I am logged in as "maria"
    And I go to /profile/maria
    Then I should see "Percentage incomplete:"

  @selenium
  Scenario: When the user logged in and hide link of imcomplete percentage and user update page, the percentage registration link must not appear
    Given the following users
      | login | name        | email             | country | state | city     |
      | maria | Maria Silva | maria@example.com | Brazil  | DF    | Brasilia |
    When I am logged in as "maria"
    And I go to /profile/maria
    And I should see "Percentage incomplete:"
    And I click on anything with selector ".hide-incomplete-percentage"
    And I should not see "Percentage incomplete:"
    And I go to /myprofile/maria/profile_editor/edit
    And I go to /profile/maria
    Then I should not see "Percentage incomplete:"

  @selenium-fixme
  Scenario: When the user press incomplete percentage link,he must be redirect to his edit profile page
    Given the following users
      | login | name        | email             | country | state | city     |
      | maria | Maria Silva | maria@example.com | Brazil  | DF    | Brasilia |
    When I am logged in as "maria"
    And I follow "Percentage incomplete: 72 %"
    Then I should see "Profile settings"
