class DoubanBook
  include HTTParty
  format :json
  base_uri 'https://api.douban.com/v2'
  debug_output

  def self.get_book(id)
    attrs = %w{title author publisher rating tags pages price summary}
    resp = get("/book/#{id}")
    if resp.code != 200
      nil
    else
      p resp.parsed_response.inspect
      book_data = resp.parsed_response.slice(*attrs)
      book_data['isbn'] = resp.parsed_response['isbn13']
      book_data['cover_url'] = resp.parsed_response['images']['large']
      book_data
    end
  end
end
