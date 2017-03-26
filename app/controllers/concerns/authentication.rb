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

  def authenticate_user
    unauthorized!('User Realm') unless access_token
  end

  def unauthorized!(realm)
    headers['WWW-Authenticate'] = %(#{AUTH_SCHEMA} realm="#{realm}")
    render(status: 401)
  end

  def authorization_request
    @authorization_request ||= request.authorization.to_s
  end

  def authenticator
    @authenticator ||= Authenticator.new(authorization_request)
  end

  def api_key
    @api_key ||= authenticator.api_key
  end

  def access_token
    @access_token ||= authenticator.access_token
  end

  def current_user
    @current_user ||= access_token.try(:user)
  end


end
