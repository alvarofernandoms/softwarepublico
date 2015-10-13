#aqui deve ter so usuario   e instituicao
class GovUserPluginController < ApplicationController

  def hide_registration_incomplete_percentage
    response = false

    if request.xhr? && params[:hide]
      session[:hide_incomplete_percentage] = true
      response = session[:hide_incomplete_percentage]
    end

    render :json=>response.to_json
  end

  def create_institution
    @show_sisp_field = environment.admins.include?(current_user.person)
    @state_list = get_state_list()
    @governmental_sphere = [[_("Select a Governmental Sphere"), 0]]|GovernmentalSphere.all.map {|s| [s.name, s.id]}
    @governmental_power = [[_("Select a Governmental Power"), 0]]|GovernmentalPower.all.map {|g| [g.name, g.id]}
    @juridical_nature = [[_("Select a Juridical Nature"), 0]]|JuridicalNature.all.map {|j| [j.name, j.id]}
    @state_options = [[_('Select a state'), '-1']] | @state_list.collect {|state| [state.name, state.name]}

    params[:community] ||= {}
    params[:institutions] ||= {}

    if request.xhr?
      render :layout=>false
    else
      redirect_to "/"
    end
  end

  def split_http_referer http_referer
    split_list = []
    split_list = http_referer.split("/")
    @url_token = split_list.last
    return @url_token
  end

  def create_institution_admin
    @show_sisp_field = environment.admins.include?(current_user.person)
    @state_list = get_state_list()
    @governmental_sphere = [[_("Select a Governmental Sphere"), 0]]|GovernmentalSphere.all.map {|s| [s.name, s.id]}
    @governmental_power = [[_("Select a Governmental Power"), 0]]|GovernmentalPower.all.map {|g| [g.name, g.id]}
    @juridical_nature = [[_("Select a Juridical Nature"), 0]]|JuridicalNature.all.map {|j| [j.name, j.id]}
    @state_options = [[_('Select a state'), '-1']] | @state_list.collect {|state| [state.name, state.name]}

    @url_token = split_http_referer request.original_url()

    params[:community] ||= {}
    params[:institutions] ||= {}

  end

  def new_institution
    redirect_to "/" if params[:community].blank? || params[:institutions].blank?

    response_message = {}

    institution_template = Community["institution"]
    add_template_in_params institution_template

    @institutions = private_create_institution
    add_environment_admins_to_institution @institutions

    response_message = save_institution @institutions

    if request.xhr? #User create institution
      render :json => response_message.to_json
    else #Admin create institution
      session[:notice] = response_message[:message] # consume the notice

      redirect_depending_on_institution_creation response_message
    end
  end

  def institution_already_exists
    redirect_to "/" if !request.xhr? || params[:name].blank?

    already_exists = !Community.where(:name=>params[:name]).empty?

    render :json=>already_exists.to_json
  end

  def get_institutions
    redirect_to "/" if !request.xhr? || params[:query].blank?

    list = Institution.search_institution(params[:query]).map{ |institution|
      {:value=>institution.name, :id=>institution.id}
    }

    render :json => list.to_json
  end

  def get_brazil_states
    redirect_to "/" unless request.xhr?

    state_list = get_state_list()
    render :json=>state_list.collect {|state| state.name }.to_json
  end

  def get_field_data
    condition = !request.xhr? || params[:query].nil? || params[:field].nil?
    return render :json=>{} if condition

    model = get_model_by_params_field

    data = model.where("name ILIKE ?", "%#{params[:query]}%").select("id, name")
    .collect { |db|
      {:id=>db.id, :label=>db.name}
    }

    other = [model.select("id, name").last].collect { |db|
      {:id=>db.id, :label=>db.name}
    }

    # Always has other in the list
    data |= other

    render :json=> data
  end

  protected

  def get_model_by_params_field
    case params[:field]
    when "software_language"
      return ProgrammingLanguage
    else
      return DatabaseDescription
    end
  end

  def get_state_list
    NationalRegion.find(
    :all,
    :conditions=>["national_region_type_id = ?", 2],
    :order=>"name"
    )
  end

  def set_institution_type
    institution_params = params[:institutions].except(:governmental_power,
                                                      :governmental_sphere,
                                                      :juridical_nature
                                                     )
    if params[:institutions][:type] == "PublicInstitution"
      PublicInstitution::new institution_params
    else
      PrivateInstitution::new institution_params
    end
  end

  def set_public_institution_fields institution
    inst_fields = params[:institutions]

    begin
      gov_power = GovernmentalPower.find inst_fields[:governmental_power]
      gov_sphere = GovernmentalSphere.find inst_fields[:governmental_sphere]
      jur_nature = JuridicalNature.find inst_fields[:juridical_nature]

      institution.juridical_nature = jur_nature
      institution.governmental_power = gov_power
      institution.governmental_sphere = gov_sphere
    rescue
      institution.errors.add(
        :governmental_fields,
        _("Could not find Governmental Power or Governmental Sphere")
      )
    end
  end

  def private_create_institution
    community = Community.new(params[:community])
    community.environment = environment
    institution = set_institution_type

    institution.name = community[:name]
    institution.community = community

    if institution.type == "PublicInstitution"
      set_public_institution_fields institution
    end

    institution.date_modification = DateTime.now
    institution.save
    institution
  end

  def add_template_in_params institution_template
    com_fields = params[:community]
    if !institution_template.blank? && institution_template.is_template
      com_fields[:template_id]= institution_template.id unless com_fields.blank?
    end
  end

  def add_environment_admins_to_institution institution
    edit_page = params[:edit_institution_page] == false
    if environment.admins.include?(current_user.person) && edit_page
      environment.admins.each do |adm|
        institution.community.add_admin(adm)
      end
    end
  end

  def save_institution institution
    inst_errors = institution.errors.messages
    com_errors = institution.community.errors.messages

    set_errors institution

    if inst_errors.empty? && com_errors.empty? && institution.valid? && institution.save
      { :success => true,
        :message => _("Institution successful created!"),
        :institution_data => {:name=>institution.name, :id=>institution.id}
      }
    else
      { :success => false,
        :message => _("Institution could not be created!"),
        :errors => inst_errors.merge(com_errors)
      }
    end
  end

  def redirect_depending_on_institution_creation response_message
    if response_message[:success]
      redirect_to :controller => "/admin_panel", :action => "index"
    else
      flash[:errors] = response_message[:errors]

      redirect_to :controller => "gov_user_plugin", :action => "create_institution_admin", :params => params
    end
  end

  def set_errors institution
    institution.valid? if institution
    institution.community.valid? if institution.community

    flash[:error_community_name] = institution.community.errors.include?(:name) ? "highlight-error" : ""
    flash[:error_community_country] = institution.errors.include?(:country) ? "highlight-error" : ""
    flash[:error_community_state] = institution.errors.include?(:state) ? "highlight-error" : ""
    flash[:error_community_city] = institution.errors.include?(:city) ? "highlight-error" : ""
    flash[:error_institution_corporate_name] = institution.errors.include?(:corporate_name) ? "highlight-error" : ""
    flash[:error_institution_cnpj] = institution.errors.include?(:cnpj) ? "highlight-error" : ""
    flash[:error_institution_governmental_sphere] = institution.errors.include?(:governmental_sphere) ? "highlight-error" : ""
    flash[:error_institution_governmental_power] = institution.errors.include?(:governmental_power) ? "highlight-error" : ""
    flash[:error_institution_juridical_nature] = institution.errors.include?(:juridical_nature) ? "highlight-error" : ""
    flash[:error_institution_sisp] = institution.errors.include?(:sisp) ? "highlight-error" : ""
  end

end