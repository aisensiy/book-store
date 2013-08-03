require 'hmac-sha1'

class UploadController < ApplicationController
  include UploadHelper
  before_filter :signin?

  def post
    uploaded_io = params[:upload]
    logger.debug uploaded_io
    p uploaded_io.inspect
    p uploaded_io.path
    resp = UploadFile.upload_to_qiniu uploaded_io.path, uploaded_io.content_type
    render status: resp.code, json: resp.body
  end

  def get_token
    token = Book.get_upload_token
    render json: {token: token}
  end

  def get_download_token
    download_file =
      UploadFile.create_download_file(params[:item_id], 'book', session[:user_id])
    render json: {link: download_file['url']}
  end

  def callback
    return_data = urlsafe_base64_decode params[:upload_ret]
    logger.debug return_data
    render json: return_data
  end

end
