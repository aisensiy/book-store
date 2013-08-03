require 'open-uri'

class UploadFile < BaseClient
  def self.upload(filename, filetype, filebody)
    headers = self.headers.merge({"Content-Type" => filetype})
    post("/1/files/#{URI::encode sanitize(filename)}", body: filebody, headers: headers)
  end

  def self.upload_to_qiniu(path, mime_type)
    token = Qiniu::RS.generate_upload_token(scope: Settings.qiniu_bucket, callback_url: '')
    begin
      Qiniu::RS.upload_file uptoken: token,
                            file: path,
                            mime_type: mime_type,
                            bucket: Settings.qiniu_bucket,
                            callback_body_type: 'application/json'
    rescue UploadFailedError => e
      {'error' => e.to_s}
    end
  end

  def self.create_download_file(item_id, type, user_id)
    obj = Parse.get type.classify, item_id
    url = type.classify.constantize.get_download_token obj['file_key'], obj['file_name']

    download_file = Parse::Object.new('DownloadFile')
    download_file['type'] = type
    download_file['url'] = url
    download_file['user_id'] = user_id

    download_file.save
  end

  private
  def self.sanitize(name)
    sanitize_regexp = /[^[:word:]\.\-\+]/
    name = name.gsub("\\", "/") # work-around for IE
    name = File.basename(name)
    name = name.gsub(sanitize_regexp, "_")
    name = "_#{name}" if name =~ /\A\.+\z/
    name = "unnamed" if name.size == 0
    return name.mb_chars.to_s
  end

  def filename
    name = Digest::MD5.hexdigest(File.dirname(current_path))
    "#{name}.#{file.extension}"
  end

end

