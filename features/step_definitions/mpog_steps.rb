Given /^SoftwareInfo has initial default values on database$/ do
  LicenseInfo.create(:version=>"None", :link=>"")
  LicenseInfo.create(:version=>"GPL-2", :link =>"www.gpl2.com")
  LicenseInfo.create(:version=>"GPL-3", :link =>"www.gpl3.com")

  ProgrammingLanguage.create(:name=>"C")
  ProgrammingLanguage.create(:name=>"C++")
  ProgrammingLanguage.create(:name=>"Ruby")
  ProgrammingLanguage.create(:name=>"Python")

  DatabaseDescription.create(:name => "Oracle")
  DatabaseDescription.create(:name => "MySQL")
  DatabaseDescription.create(:name => "Apache")
  DatabaseDescription.create(:name => "PostgreSQL")

  OperatingSystemName.create(:name=>"Debian")
  OperatingSystemName.create(:name=>"Fedora")
  OperatingSystemName.create(:name=>"CentOS")
end

Given /^Institutions has initial default values on database$/ do
  GovernmentalPower.create(:name => "Executivo")
  GovernmentalPower.create(:name => "Legislativo")
  GovernmentalPower.create(:name => "Judiciario")

  GovernmentalSphere.create(:name => "Federal")
end

Given /^I type in "([^"]*)" into autocomplete list "([^"]*)" and I choose "([^"]*)"$/ do |typed, input_institution, should_select|
   page.driver.browser.execute_script %Q{ jQuery('input[data-autocomplete]').trigger("focus") }
   fill_in("#{input_institution}",:with => typed)
   page.driver.browser.execute_script %Q{ jQuery('input[data-autocomplete]').trigger("keydown") }
   sleep 1
   page.driver.browser.execute_script %Q{ jQuery('.ui-menu-item a:contains("#{should_select}")').trigger("mouseenter").trigger("click"); }
end

Given /^the following public institutions?$/ do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |item|
    governmental_power = GovernmentalPower.where(:name => item[:governmental_power]).first
    governmental_sphere = GovernmentalSphere.where(:name => item[:governmental_sphere]).first
    institution = PublicInstitution.create!(:name => item[:name], :type => "PublicInstitution", :acronym => item[:acronym], :cnpj => item[:cnpj], :governmental_power => governmental_power, :governmental_sphere => governmental_sphere)
    institution.save!
  end
end

Given /^the following software language$/ do |table|
  table.hashes.each do |item|
    programming_language = ProgrammingLanguage.where(:name=>item[:programing_language]).first
    software_language = SoftwareLanguage::new

    software_language.programming_language = programming_language
    software_language.version = item[:version]
    software_language.operating_system = item[:operating_system]

    software_language.save!
  end
end

Given /^the following software databases$/ do |table|
  table.hashes.each do |item|
    database_description = DatabaseDescription.where(:name=>item[:database_name]).first
    software_database = SoftwareDatabase::new

    software_database.database_description = database_description
    software_database.version = item[:version]
    software_database.operating_system = item[:operating_system]

    software_database.save!
  end
end


Given /^the following operating systems$/ do |table|
  table.hashes.each do |item|
    operating_system_name = OperatingSystemName.where(:name=>item[:operating_system_name]).first
    operating_system = OperatingSystem::new

    operating_system.operating_system_name = operating_system_name
    operating_system.version = item[:version]

    operating_system.save!
  end
end

Given /^the following softwares$/ do |table|
  table.hashes.each do |item|
    community = Community.create :name=>item[:name]
    programming_language = ProgrammingLanguage.where(:name=>item[:software_language]).first
    database_description = DatabaseDescription.where(:name=>item[:software_database]).first

    software_language = SoftwareLanguage.where(:programming_language_id=>programming_language).first
    software_database = SoftwareDatabase.where(:database_description_id=>database_description).first

    operating_system_name = OperatingSystemName.where(:name => item[:operating_system]).first
    operating_system = OperatingSystem.where(:operating_system_name_id => operating_system_name).first
    
    software_info = SoftwareInfo::new(:acronym=>item[:acronym], :operating_platform=>item[:operating_platform])
    software_info.community = community
    software_info.software_languages << software_language
    software_info.software_databases << software_database
    software_info.operating_systems << operating_system
    software_info.save!
  end
end

# Dynamic table steps
Given /^I fill in first "([^"]*)" class with "([^"]*)"$/ do |selector, value|
  evaluate_script "jQuery('#{selector}').first().attr('value', '#{value}') && true"
end

Given /^I fill in last "([^"]*)" class with "([^"]*)"$/ do |selector, value|
  evaluate_script "jQuery('#{selector}').last().attr('value', '#{value}') && true"
end

Given /^I click on the first button with class "([^"]*)"$/ do |selector|
  evaluate_script "jQuery('#{selector}').first().trigger('click') && true"
end

Given /^I click on the last button with class "([^"]*)"$/ do |selector|
  evaluate_script "jQuery('#{selector}').last().trigger('click') && true"
end

Given /^the user "([^"]*)" has "([^"]*)" as secondary e\-mail$/ do |login, email|
  User[login].update_attributes(:secondary_email => email)
end

Given /^I click on anything with selector "([^"]*)"$/ do |selector|
  evaluate_script "jQuery('#{selector}').trigger('click') && true"
end

Given /^I should see "([^"]*)" of this selector "([^"]*)"$/ do |quantity, selector|
  evaluate_script "jQuery('#{selector}').length == '#{quantity}'"
end

Given /^selector "([^"]*)" should have any "([^"]*)"$/ do |selector, text|
  evaluate_script "jQuery('#{selector}').html().indexOf('#{text}') != -1"
end

Given /^I click on table number "([^"]*)" selector "([^"]*)" and select the value "([^"]*)"$/ do |number, selector, value|
  evaluate_script "jQuery('#{selector}:nth-child(#{number}) select option:contains(\"#{value}\")').selected() && true"
end

Given /^I fill with "([^"]*)" in field with name "([^"]*)" of table number "([^"]*)" with class "([^"]*)"$/ do |value, name, number, selector|
  evaluate_script "jQuery('#{selector}:nth-child(#{number}) input[name=\"#{name}\"]').val('#{value}') && true"
end

Given /^I sleep for (\d+) seconds$/ do |time|
  sleep time.to_i
end
