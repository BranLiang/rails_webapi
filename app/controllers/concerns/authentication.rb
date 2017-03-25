module Authentication
  include ActiveSupport::SecurityUtils
  extend ActiveSupport::Concern

  AUTH_SCHEMA = 'Alexandria-Token'

  included do
    before_action :validate_auth_schema
    before_action :authenticate_client
  end

  def validate_auth_schema
    unless authorization_request.match(/^#{AUTH_SCHEMA}/)
      unauthorized!('Client Realm')
    end
  end

  def authenticate_client
    unauthorized!('Clent Realm') unless api_key
  end

  def unauthorized!(realm)
    headers['WWW-Authenticate'] = %(#{AUTH_SCHEMA} realm="#{realm}")
    render(status: 401)
  end

  def authorization_request
    @authorization_request ||= request.authorization.to_s
  end

  def credentials
    @credentials ||= Hash[authorization_request.scan(/(\w+)[:=] ?"?([\w|:]+)"?/)]
  end

  def api_key
    @api_key ||= compute_api_key
  end

  def compute_api_key
    return nil if credentials['api_key'].blank?

    access_key, key = credentials['api_key'].split(':')
    api_key = access_key && key && ApiKey.activated.find_by(access_key: access_key)

    return api_key if api_key && secure_compare_with_hashing(api_key.key, key)
  end

  def secure_compare_with_hashing(a, b)
    secure_compare(Digest::SHA1.hexdigest(a), Digest::SHA1.hexdigest(b))
  end


end
