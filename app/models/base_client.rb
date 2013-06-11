class BaseClient
  include HTTParty
  headers "X-Parse-Application-Id" => Settings.parse_appid,
          "X-Parse-REST-API-Key" => Settings.parse_restid,
          "Content-Type" => "application/json"
  format :json
  base_uri 'https://api.parse.com'
  debug_output

  def self.set_session_token(token)
    headers['X-Parse-Session-Token'] = token
  end

  def self.remove_session_token
    headers.delete! 'X-Parse-Session-Token'
  end
end
