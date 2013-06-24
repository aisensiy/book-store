class BooksController < ApplicationController
  def index
    resp = Book.get_books(params[:limit], params[:skip])
    render status: resp.code, json: resp
  end

  def create
    # get douban data
    book_data = DoubanBook.get_book get_book_id_from_url(params[:book][:url])
    if not book_data
      render status: 404, json: { error: 'book not found' }
      return
    end
    # params[:book].delete :url

    # upload file
    # uploaded_io = params[:upload]
    # upload_resp = UploadFile.upload_to_qiniu uploaded_io.path, uploaded_io.content_type
    # if upload_resp['error']
    #   render 403, json: upload_resp['error']
    # end

    # params[:book][:file_key] = upload_resp['key']

    book_data.merge! params[:book]

    # create book
    resp = Book.create_book(book_data)

    if resp.code == 201
      book_data[:objectId] = resp['objectId']
      render status: 201, json: {objectId: resp['objectId']}
    else
      render status: resp.code, json: resp.body
    end
  end

  def update
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
