class BaseClient
  include HTTParty
  headers "X-Parse-Application-Id" => Settings.parse_appid,
          "X-Parse-REST-API-Key" => Settings.parse_restid,
          "Content-Type" => "application/json"
  format :json
  base_uri 'https://api.parse.com'
end
