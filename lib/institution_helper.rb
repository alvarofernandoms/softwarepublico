require "net/http"
require "yaml"

module InstitutionHelper

  SPHERES = ['federal']
  POWERS = ['executive', 'legislative', 'judiciary']

  def self.mass_update
    @web_service_info = self.web_service_info

    POWERS.each do |power|
      SPHERES.each do |sphere|
        json = self.get_json power, sphere

        units = json["unidades"]

        units.each do |unit|
          institution = Institution.where(:name=>unit["nome"])

          institution = if institution.count == 0
            Institution::new
          else
            institution.first
          end

          institution = self.set_institution_data institution, unit
          institution.save
        end
      end
    end
  end

  protected

  def self.web_service_info
    YAML.load_file(File.dirname(__FILE__) + '/../config/siorg.yml')['web_service']
  end

  def self.service_url power, sphere
    base_url = @web_service_info['base_url']
    power_code = @web_service_info['power_codes'][power].to_s
    sphere_code = @web_service_info['sphere_codes'][sphere].to_s
    additional_params = @web_service_info['additional_params']

    return URI("#{base_url}?codigoPoder=#{power_code}&codigoEsfera=#{sphere_code}&#{additional_params}")
  end

  def self.get_json power, sphere
    uri = self.service_url power, sphere #URI(BASE_URL+"codigoPoder=#{power_code}&codigoEsfera=#{sphere_code}&retornarOrgaoEntidadeVinculados=NAO")
    data = Net::HTTP.get(uri)
    ActiveSupport::JSON.decode(data)
  end

  def self.retrieve_code unit, field
    data = unit[field]
    return data.split("/").last unless (data.blank? || data.nil?)
    return nil
  end

  def self.set_institution_data institution, unit
    institution.name = unit["nome"]
    institution.acronym  = unit["sigla"]
    institution.unit_code = self.retrieve_code(unit,"codigoUnidade")
    institution.parent_code = self.retrieve_code(unit,"codigoUnidadePai")
    institution.unit_type = self.retrieve_code(unit,"codigoTipoUnidade")
    institution.juridical_nature = self.retrieve_code(unit,"codigoNaturezaJuridica")
    institution.sub_juridical_nature = self.retrieve_code(unit,"codigoSubNaturezaJuridica")
    institution.normalization_level = unit["nivelNormatizacao"]
    institution.version = unit["versaoConsulta"]
    institution.type = "PublicInstitution"
    institution.governmental_power = GovernmentalPower.where(:name=>self.retrieve_code(unit,"codigoPoder")).first
    institution.governmental_sphere = GovernmentalSphere.where(:name=>self.retrieve_code(unit,"codigoEsfera")).first
    institution
  end
end
