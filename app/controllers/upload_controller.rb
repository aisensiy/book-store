require 'hmac-sha1'

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
      returnBody: '{"is_public": $(x:is_public), "content_type": $(mimeType), "file_key": $(etag), "url": $(x:url), "lang": $(x:lang), "size": $(fsize)}'
    )
    render json: {token: token}
  end

  def get_download_token
    opts = {
      scope: Settings.qiniu_bucket,
      deadline: Time.now.to_i + 1.hour,
      key: params[:file_key]
    }
    token = generate_download_token(opts)
    url = "http://#{opts[:scope]}.qiniudn.com/#{opts[:key]}?e=#{opts[:deadline]}&token=#{token}"
    render json: {link: url}
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

  def generate_download_token(opts={})
    url = "http://#{opts[:scope]}.qiniudn.com/#{opts[:key]}?e=#{opts[:deadline]}"
    encode_sign = generate_encoded_digest(url)
    %Q(#{Settings.qiniu_appkey}:#{encode_sign})
  end
end
