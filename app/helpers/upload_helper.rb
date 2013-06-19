require 'base64'
require 'hmac-sha1'

module UploadHelper
  def urlsafe_base64_encode(content)
    Base64.encode64(content).strip.gsub('+', '-').gsub('/','_').gsub(/\r?\n/, '')
  end

  def urlsafe_base64_decode encoded_content
    Base64.decode64 encoded_content.gsub('_','/').gsub('-', '+')
  end

  def urlsafe_base64_decode encoded_content
    Base64.decode64 encoded_content.gsub('_','/').gsub('-', '+')
  end

  def generate_encoded_digest(signature)
    hmac = HMAC::SHA1.new(Settings.qiniu_appsecret)
    hmac.update(signature)
    urlsafe_base64_encode(hmac.digest)
  end

end
