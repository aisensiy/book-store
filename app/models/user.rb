class User < BaseClient
  def self.signup(options)
    post('/1/users', body: JSON.dump(options))
  end
end
