class BooksController < ApplicationController
  include UploadHelper
  before_filter :signin?, only: [:create, :update, :get_own_books, :destroy]

  def index
    resp = Book.get_books(params[:limit], params[:skip], where: {'is_public' => true})
    logger.debug resp.inspect
    process_authorities(resp.parsed_response['results'])
    render status: resp.code, json: resp
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
    resp = Book.update_book(params[:id], session[:token], params[:book])
    render status: resp.code, json: resp.body
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

  private
  def get_book_id_from_url(url)
    mat = url.match(/(\d+)\/?$/)
    return nil if not mat
    mat[1]
  end

  def write_authority(book)
    return if !session[:user_id]
    cur_user = session[:user_id]
    role = session[:user_role] || "Members"
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
    token = urlsafe_base64_encode "#{Settings.qiniu_bucket}:#{file_key}"
    url = "http://rs.qbox.me/delete/#{token}"
    access_token = generate_access_token(Settings.qiniu_appkey, Settings.qiniu_appsecret, url, nil)
    Book.delete_file(url, access_token)
  end
end
