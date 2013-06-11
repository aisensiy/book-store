class User < BaseClient
  def self.signup(options)
    post('/1/users', body: JSON.dump(options))
  end

  def self.remove(user_id, token)
    headers = self.headers.merge({'X-Parse-Session-Token' => token})
    delete("/1/users/#{user_id}", headers: headers)
  end
end
