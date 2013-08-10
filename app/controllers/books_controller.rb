class BooksController < ApplicationController
  before_filter :signin?, only: [:send_to_device, :create, :update, :get_own_books, :destroy]

  def index
    resp = Book.get_books(params[:limit], params[:skip], where: {'is_public' => true})
    process_authorities(resp.parsed_response['results'])
    render status: resp.code, json: resp
  end

  def month_top
    cur_month = Time.now.strftime('%Y %M')
    books = range_top('month', cur_month, 'book', params[:limit] || 10)
    render status: 200, json: books
  end

  def week_top
    cur_week = Time.now.strftime('%Y %W')
    books = range_top('week', cur_week, 'book', params[:limit] || 10)
    render status: 200, json: books
  end

  def recommend
    books = Parse::Query.new('Book').tap do |q|
      q.greater_than 'priority', 0
      q.or(Parse::Query.new('Book').tap do |or_query|
        or_query.eq('objectId', {
          '$select' => {
            'query' => {
              'className' => 'DownloadRecord',
              'where' => {
                'range' => '',
                'range_type' => 'total',
                'type' => 'book'
              }
            },
            'key' => 'item_id',
            'order_by' => '-count',
            'limit' => params[:limit]
          }
        })
      end)
      q.order_by = '-priority,-count'
      q.limit = params[:limit]
    end.get

    render status: 200, json: books
  end

  def own
    resp = Book.get_books(params[:limit], params[:skip], where: {'user_id' => session[:user_id]})
    render status: resp.code, json: resp
  end

  def create
    if params[:book][:url] =~ /douban/
    # get douban data
      book_data = DoubanBook.get_book get_book_id_from_url(params[:book][:url])
    else
      book_data = AmazonBook.get_book params[:book][:url]
    end

    if not book_data
      render status: 404, json: { error: 'book not found' }
      return
    end

    book_data.merge! params[:book]
    book_data[:user_id] = session[:user_id]

    # create book
    resp = Book.create_book(session[:user_id], book_data)

    if resp.code == 201
      book_data[:objectId] = resp['objectId']
      render status: 201, json: {objectId: resp['objectId']}
    else
      render status: resp.code, json: resp.body
    end
  end

  def update
    begin
      book = Parse.get('Book', params[:id])
      book.send :parse, params[:book]
      book.save
      render json: book
    # resp = Book.update_book(params[:id], session[:token], book_params)
    # render status: resp.code, json: resp.body
    rescue Exception => e
      render 403, json: e
    end

  end

  def destroy
    resp = Book.delete_book(params[:id], session[:token])
    delete_file(params[:file_key]) if resp.code == 200
    render status: resp.code, json: resp
  end

  def show
    resp = Book.get_book(params[:id])
    write_authority(resp.parsed_response)
    render status: resp.code, json: resp
  end

  def send_to_device
    user = User.get_user(session[:user_id]).parsed_response
    resp = Push.send_url_to_user_device(user, 'book', params[:id])
    render status: resp.code, json: resp
  end

  private

  def book_params
    params.require(:book).permit(:author, :cover_url, :is_public, :isbn, :lang,
                                 :priority, :publisher, :rate, :rating, :summary,
                                 :tags, :title, :url)
  end

  def range_top(range_type, range, type, limit)
    Parse::Query.new('Book').tap do |book_query|
      book_query.eq('objectId', {
        '$select' => {
          'query' => {
            'className' => 'DownloadRecord',
            'where' => {
              'range' => range,
              'range_type' => range_type,
              'type' => type
            }
          },
          'key' => 'item_id',
          'order_by' => '-count',
          'limit' => limit
        }
      })
    end.get
  end

  def get_book_id_from_url(url)
    mat = url.match(/(\d+)\/?$/)
    return nil if not mat
    mat[1]
  end

  def write_authority(book)
    return if !session[:user_id]
    cur_user = session[:user_id]
    role = session[:user_role] || "Members"
    logger.debug '=' * 20
    logger.debug role
    logger.debug book['ACL']['write'].inspect
    if book['ACL'][cur_user] && book['ACL'][cur_user]['write'] == true ||
       book['ACL']["role:#{role}"] && book['ACL']["role:#{role}"]["write"] == true
      book['write'] = true
    end
    book
  end

  def process_authorities(books)
    books.each do |book|
      write_authority(book)
    end
    books
  end

  def delete_file(file_key)
    Book.delete_file(file_key)
  end

end
