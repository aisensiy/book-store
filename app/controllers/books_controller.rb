class BooksController < ApplicationController
  def index
    resp = Book.get_books()
    render status: resp.code, json: resp['results']
  end

  def create
    # get douban data
    book_data = DoubanBook.get_book get_book_id_from_url(params[:book][:url])
    if not book_data
      render status: 404, json: { error: 'book not found' }
      return
    end
    params[:book].delete :url

    # upload file
    uploaded_io = params[:upload]
    upload_resp = UploadFile.upload uploaded_io.original_filename,
                             uploaded_io.content_type,
                             uploaded_io.read

    if upload_resp.code != 201
      render upload_resp.code, json: upload_resp.body
    end

    params[:book][:file] = {
      name: upload_resp.parsed_response['name'],
      __type: 'File'
    }

    book_data.merge! params[:book]

    # create book
    resp = Book.create_book(book_data)

    if resp.code == 201
      book_data[:objectId] = resp['objectId']
      render status: 201, json: book_data
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
