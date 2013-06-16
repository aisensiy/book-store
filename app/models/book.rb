class Book < BaseClient
  def self.create_book(options)
    post('/1/classes/books', body: JSON.dump(options))
  end
end
