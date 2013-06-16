class Book < BaseClient
  def self.create_book(options)
    post('/1/classes/books', body: JSON.dump(options))
  end

  def self.get_book(id)
    get("/1/classes/books/#{id}")
  end
end
