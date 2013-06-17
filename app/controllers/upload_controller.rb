class UploadController < ApplicationController
  def post
    uploaded_io = params[:upload]
    logger.debug uploaded_io
    p uploaded_io.inspect
    p uploaded_io.path
    resp = UploadFile.upload_to_qiniu uploaded_io.path, uploaded_io.content_type
    render status: resp.code, json: resp.body
  end
end
