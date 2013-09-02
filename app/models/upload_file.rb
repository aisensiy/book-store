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

  def self.create_download_file(item_id, type, user_id, deadline=1.hour)
    client = Klass.new(type.classify)
    obj = client.get item_id
    url = client.get_download_token obj['file_key'], obj['file_name'], deadline

    download_file = Parse::Object.new('DownloadFile')
    download_file['type'] = type
    download_file['url'] = url
    download_file['user_id'] = user_id

    download_file.save

    if download_file.id
      self.create_or_increase_download_record(item_id, type)
    end

    download_file
  end

  private
  def self.create_or_increase_download_record(item_id, type)
    time = Time.now
    cur_week = time.strftime '%Y %W'
    cur_month = time.strftime '%Y %m'

    self.create_or_increase_reccord(item_id, type, cur_week, 'week')
    self.create_or_increase_reccord(item_id, type, cur_month, 'month')
    self.create_or_increase_reccord(item_id, type, '', 'total')
  end

  def self.create_or_increase_reccord(item_id, type, range, range_type)
    record = Parse::Query.new('DownloadRecord').eq('item_id', item_id).eq('range_type', range_type).eq('range', range).get.first
    if record.nil?
      self.create_download_record(item_id, type, range, range_type)
    else
      self.increase_download_record(record)
    end
  end

  def self.create_download_record(item_id, type, range, range_type)
    obj = Parse::Object.new('DownloadRecord',
                            {
                              'item_id' => item_id,
                              'type' => type,
                              'range' => range,
                              'range_type' => range_type,
                              'count' => 1
                            }
                           )
    obj.save
  end

  def self.increase_download_record(obj)
    obj['count'] = Parse::Increment.new(1)
    obj.save
  end
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

