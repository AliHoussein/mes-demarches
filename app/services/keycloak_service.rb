class KeycloakService
  def self.authorization_uri
    client = KeycloakClient.new

    client.authorization_uri(
      scope: [:profile, :email],
      state: SecureRandom.hex(16),
      nonce: SecureRandom.hex(16)
    )
  end

  def self.retrieve_user_informations_particulier(code)
    client = KeycloakClient.new(code)

    client_access_token = client.access_token!(client_auth_method: :secret)
    user_info = client_access_token.userinfo!.raw_attributes

    FranceConnectInformation.new(
      gender: user_info[:gender],
      given_name: user_info[:given_name],
      family_name: user_info[:family_name],
      email_france_connect: user_info[:email],
      birthdate: user_info[:birthdate],
      birthplace: user_info[:birthplace],
      france_connect_particulier_id: user_info[:sub]
    )
  end
end
