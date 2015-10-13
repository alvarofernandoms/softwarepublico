module PluginTestHelper

  def create_community name
    community = fast_create(Community)
    community.name = name
    community.identifier = name.to_slug
    community.save
    community
  end

  def create_software_info name, finality = "something", acronym = ""
    community = create_community(name)
    software_info = SoftwareInfo.new
    software_info.community = community
    software_info.finality = finality
    software_info.acronym = acronym
    software_info.public_software = true
    software_info.save!

    software_info
  end

  def create_person name, email, password, password_confirmation, state, city
    user = create_user(
      name.to_slug,
      email,
      password,
      password_confirmation,
    )
    person = Person::new

    user.person = person
    person.user = user

    person.name = name
    person.identifier = name.to_slug
    person.state = state
    person.city = city

    user.save
    person.save

    person
  end

  def create_user login, email, password, password_confirmation
    user = User.new

    user.login = login
    user.email = email
    user.password = password
    user.password_confirmation = password_confirmation

    user
  end

  def create_license_info version, link = ""
    license = LicenseInfo.create(:version => version)
    license.link = link
    license.save

    license
  end
end
