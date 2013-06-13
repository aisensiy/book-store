class UploadController < ApplicationController
  def post
    uploaded_io = params[:upload]
    resp = UploadFile.upload uploaded_io.original_filename,
                      uploaded_io.content_type,
                      uploaded_io.read
    render status: resp.code, json: resp.body
  end
end
