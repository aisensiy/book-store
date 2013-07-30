class Book < BaseClient
  extend UploadHelper

  def self.create_book(user_id, options)
    options[:ACL] = {
      "*" => {
        "read" => true
      },
      "role:Admins" => {
        "write" => true
      },
      user_id => {
        "write" => true
      }
    }
    post('/1/classes/Book', body: JSON.dump(options))
  end

  def self.update_book(book_id, token, options)
    headers = self.headers.merge({'X-Parse-Session-Token' => token})
    put("/1/classes/Book/#{book_id}", body: JSON.dump(options), headers: headers)
  end

  def self.get_book(id)
    get("/1/classes/Book/#{id}")
  end

  def self.get_books(limit=40, skip=0, where={})
    query = {count: 1, limit: limit, skip: skip, order: '-createdAt'}
    query[:where] = where[:where].to_json if where[:where]
    get("/1/classes/Book", query: query)
  end

  def self.delete_book(id, token)
    headers = self.headers.merge({'X-Parse-Session-Token' => token})
    delete("/1/classes/Book/#{id}", headers: headers)
  end

  def self.delete_file(file_key)
    token = self.urlsafe_base64_encode "#{Settings.qiniu_bucket}:#{file_key}"
    url = "http://rs.qbox.me/delete/#{token}"
    access_token = self.generate_access_token(Settings.qiniu_appkey, Settings.qiniu_appsecret, url, nil)
    headers = {"Authorization" => "QBox #{access_token}"}
    post(url, headers: headers)
  end

  def self.get_download_token(file_key, file_name)
    opts = {
      scope: Settings.qiniu_bucket,
      deadline: Time.now.to_i + 1.hour,
      key: file_key
    }
    token = self.generate_download_token(opts, file_name)
    "http://#{opts[:scope]}.qiniudn.com/#{opts[:key]}?download/#{file_name}&e=#{opts[:deadline]}&token=#{token}"
  end

  def self.get_upload_token()
    self.generate_upload_token(
      scope: Settings.qiniu_bucket,
      deadline: Time.now.to_i + 1.hour,
      returnBody: '{"file_name": $(fname), "is_public": $(x:is_public), "content_type": $(mimeType), "file_key": $(etag), "url": $(x:url), "lang": $(x:lang), "size": $(fsize)}'
    )
  end

  private
  def self.generate_upload_token(opts={})
    signature = urlsafe_base64_encode(opts.to_json)
    encoded_digest = self.generate_encoded_digest(signature)
    %Q(#{Settings.qiniu_appkey}:#{encoded_digest}:#{signature})
  end

  def self.generate_download_token(opts={}, file_name)
    url = "http://#{opts[:scope]}.qiniudn.com/#{opts[:key]}?download/#{file_name}&e=#{opts[:deadline]}"
    encode_sign = self.generate_encoded_digest(url)
    %Q(#{Settings.qiniu_appkey}:#{encode_sign})
  end

  def self.generate_encoded_entry_uri(file_key)
    urlsafe_base64_encode "#{file_key}:#{Settings.qiniu_bucket}"
  end
end
