class BooksController < ApplicationController
  before_filter :signin?, only: [:create, :update, :get_own_books]

  def index
    resp = Book.get_books(params[:limit], params[:skip], where: {'is_public' => true})
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
  end

  def show
    resp = Book.get_book(params[:id])
    render status: resp.code, json: resp.body
  end

  private
  def get_book_id_from_url(url)
    mat = url.match(/(\d+)\/?$/)
    return nil if not mat
    mat[1]
  end
end
