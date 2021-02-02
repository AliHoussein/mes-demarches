class Champs::NumeroDnController < ApplicationController
  before_action :authenticate_logged_user!

  def show
    set_dn_ddn
    if @dn.empty?
      return @status = :empty
    end
    if !/\d{6,7}/.match?(@dn)
      return @status = :bad_dn_format
    end
    begin
      @ddn = Date.parse(@ddn)
      # don't even call CPS WS if user has not finished giving the year (0196)
      return :bad_ddn_format if @ddn.year < 1900
    rescue
      return @status = :bad_ddn_format
    end
    check_dn
  end

  private

  def set_dn_ddn
    @base_id = "dossier_"
    champs   = params[:dossier]
    loop do
      key = champs.keys[0]
      champs = champs[key]
      @base_id += key + '_'
      return if champs.empty?
      break if champs.key?(:numero_dn) || champs.key?(:date_de_naissance)
    end
    @ddn = champs[:date_de_naissance] || params[:ddn]
    @dn  = champs[:numero_dn] || params[:dn]
  end

  def check_dn
    result = ApiCPS::API.new().verify({ @dn => @ddn })
    case result[@dn]
    when 'true'
      @status = :good_dn
    when 'false'
      @status = :bad_ddn
    else
      @status = :bad_dn
    end
  rescue ApiEntreprise::API::Error::RequestFailed
    @status = :network_error
  end

  def find_etablissement_with_siret
    etablissement_attributes = ApiEntrepriseService.get_etablissement_params_for_siret(@siret, @procedure_id)
    if etablissement_attributes.present?
      Etablissement.new(etablissement_attributes)
    end
  end

  def clear_siret_and_etablissement
    @champ&.update!(value: '')
    @etablissement&.destroy
  end

  def siret_error(error)
    clear_siret_and_etablissement
    @siret = error
  end
end
