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

  def generate_access_token(access_key, secret_key, url, params)
    uri = URI.parse(url)
    access = uri.path
    query_string = uri.query
    access += '?' + query_string if !query_string.nil? && !query_string.empty?
    access += "\n";
    if params.is_a?(Hash)
        total_param = params.map do |key, value|
            %Q(#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s).gsub('+', '%20')})
        end
        access += total_param.join("&")
    end
    hmac = HMAC::SHA1.new(secret_key)
    hmac.update(access)
    encoded_digest = urlsafe_base64_encode(hmac.digest)
    %Q(#{access_key}:#{encoded_digest})
  end
end
