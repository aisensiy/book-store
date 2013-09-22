class BooksController < ApplicationController
  include AppHelper
  before_filter :signin?, only: [:send_to_device, :create, :update, :get_own_books, :destroy]

  before_filter do
    @BookClient = Klass.new('Book')
  end

  def index
    where = {"is_public" => true}
    query_with_where(where)
  end

  def search
    where = {'$or' => [{'title' => {'$regex' => params[:q]}}]}
    query_with_where(where)
  end

  def tag
    where = {"tags" => params[:tag]}
    query_with_where(where)
  end

  def month_top
    cur_month = Time.now.strftime('%Y %m')
    books = @BookClient.range_top('month', cur_month, params[:limit] || 10)
    render status: 200, json: books
  end

  def week_top
    cur_week = Time.now.strftime('%Y %W')
    books = @BookClient.range_top('week', cur_week, params[:limit] || 10)
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
    resp = @BookClient.query(params[:limit], params[:skip], where: {'user_id' => session[:user_id]})
    render status: resp.code, json: resp
  end

  def create
    book_data = {}

    if params[:book][:url]
      if params[:book][:url] =~ /douban/
      # get douban data
        book_data = DoubanBook.get_book get_book_id_from_url(params[:book][:url])
      else
        book_data = AmazonBook.get_book params[:book][:url]
      end
    end

    if not book_data
      render status: 404, json: { error: 'book not found' }
      return
    end

    book_data.merge! params[:book]
    book_data[:user_id] = session[:user_id]

    # create book
    resp = @BookClient.create(session[:user_id], book_data)

    if resp.code == 201
      book_data[:objectId] = resp['objectId']
      render status: 201, json: {objectId: resp['objectId']}
    else
      render status: resp.code, json: resp.body
    end
  end

  def update
    begin
      resp = @BookClient.update(params[:id], session[:token], book_params)
      render status: resp.code, json: resp.body
    rescue Exception => e
      render 403, json: e
    end

  end

  def destroy
    @BookClient.destroy(params[:id], session[:token])
    @BookClient.delete_file(params[:file_key])
    render status: 200, json: {}
  end

  def show
    resp = @BookClient.get(params[:id])
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
    params.require(:book).permit(:cover_url, :is_public, :isbn, :lang, :priority, :publisher, :rate, :rating, :summary, :title, :url, :tags => [], :author => [])
  end

  def get_book_id_from_url(url)
    mat = url.match(/(\d+)\/?$/)
    return nil if not mat
    mat[1]
  end

  def query_with_where(where)
    resp = @BookClient.query(params[:limit], params[:skip], where: where)
    process_authorities(resp.parsed_response['results'])
    render status: resp.code, json: resp
  end
end
