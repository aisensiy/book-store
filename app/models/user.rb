class User < BaseClient
  def self.signup(options)
    post('/1/users', body: JSON.dump(options))
  end

  def self.remove(user_id, token)
    headers = self.headers.merge({'X-Parse-Session-Token' => token})
    delete("/1/users/#{user_id}", headers: headers)
  end

  def self.signin(options={})
    get('/1/login', query: options)
  end

  def self.update(user_id, token, options={})
    headers = self.headers.merge({'X-Parse-Session-Token' => token})
    put("/1/users/#{user_id}", body: JSON.dump(options), headers: headers)
  end

  def self.password_reset(email)
    post("/1/requestPasswordReset", body: JSON.dump({email: email}))
  end
end
