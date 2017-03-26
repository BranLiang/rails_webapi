class Authenticator
  include ActiveSupport::SecurityUtils

  def initialize(authorization)
    @authorization = authorization
  end

  def api_key
    return nil if credentials['api_key'].blank?

    access_key, key = credentials['api_key'].split(':')
    api_key = access_key && key && ApiKey.activated.find_by(access_key: access_key)

    return api_key if api_key && secure_compare_with_hashing(api_key.key, key)
  end

  def access_token
    return nil if credentials['access_token'].blank?

    id, token = credentials['access_token'].split(':')
    user = id && token && User.find_by(id: id)
    access_token = user && api_key && AccessToken.find_by(user: user, api_key: api_key)

    return nil unless access_token

    if access_token.expired?
      access_token.destroy
      return nil
    end

    return access_token if access_token.authenticate(token)
  end

  private

  def credentials
    @credentials ||= Hash[@authorization.scan(/(\w+)[:=] ?"?([\w|:]+)"?/)]
  end

  def secure_compare_with_hashing(a, b)
    secure_compare(Digest::SHA1.hexdigest(a), Digest::SHA1.hexdigest(b))
  end

end
