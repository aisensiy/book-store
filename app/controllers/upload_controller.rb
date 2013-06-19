class UploadController < ApplicationController
  include UploadHelper

  def post
    uploaded_io = params[:upload]
    logger.debug uploaded_io
    p uploaded_io.inspect
    p uploaded_io.path
    resp = UploadFile.upload_to_qiniu uploaded_io.path, uploaded_io.content_type
    render status: resp.code, json: resp.body
  end

  def get_token
    token = generate_upload_token(
      scope: Settings.qiniu_bucket,
      deadline: Time.now.to_i + 1.hour,
      returnUrl: url_for(controller: 'upload', action: 'callback'),
      returnBody: '{"is_public": $(x:is_public), "content_type": $(mimeType), "file_key": $(etag), "url": $(x:url)}'
    )
    render json: {token: token}
  end

  def callback
    return_data = urlsafe_base64_decode params[:upload_ret]
    logger.debug return_data
    render json: return_data
  end

  private
  def generate_upload_token(opts={})
    signature = urlsafe_base64_encode(opts.to_json)
    encoded_digest = generate_encoded_digest(signature)
    %Q(#{Settings.qiniu_appkey}:#{encoded_digest}:#{signature})
  end
end
