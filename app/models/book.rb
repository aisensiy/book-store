class Book < BaseClient
  def self.create_book(user_id, options)
    options[:ACL] = {
      "*" => {
        "read" => true
      },
      "role:Admins" => {
        "write" => true
      },
      user_id => {
        "write" => true
      }
    }
    post('/1/classes/Book', body: JSON.dump(options))
  end

  def self.update_book(book_id, token, options)
    headers = self.headers.merge({'X-Parse-Session-Token' => token})
    put("/1/classes/Book/#{book_id}", body: JSON.dump(options), headers: headers)
  end

  def self.get_book(id)
    get("/1/classes/Book/#{id}")
  end

  def self.get_books(limit=40, skip=0)
    get("/1/classes/Book", query: {count: 1, limit: limit, skip: skip, keys: 'title,author,cover_url,rate', order: '-createdAt'})
  end


end
