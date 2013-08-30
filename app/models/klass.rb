class Klass < BaseClient
  def initialize(klass)
    @klass = klass
  end

  def create(user_id, options={})
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
    self.class.post('/1/classes/#{@klass}', body: JSON.dump(options))
  end

  def update(id, token, options)
    headers = self.class.headers.merge({'X-Parse-Session-Token' => token})
    self.class.put("/1/classes/#{@klass}/#{id}", body: JSON.dump(options), headers: headers)
  end

  def get(id)
    self.class.get("/1/classes/#{@klass}/#{id}")
  end

  def query(limit=40, skip=0, where={})
    kuery = {count: 1, limit: limit, skip: skip, order: '-createdAt'}
    kuery[:where] = where[:where].to_json if where[:where]
    self.class.get("/1/classes/#{@klass}", query: kuery)
  end

  def destroy(id, token)
    headers = self.class.headers.merge({'X-Parse-Session-Token' => token})
    self.class.delete("/1/classes/#{@klass}/#{id}", headers: headers)
  end

  def delete_file(file_key)
    token = self.urlsafe_base64_encode "#{Settings.qiniu_bucket}:#{file_key}"
    url = "http://rs.qbox.me/delete/#{token}"
    access_token = self.generate_access_token(Settings.qiniu_appkey, Settings.qiniu_appsecret, url, nil)
    headers = {"Authorization" => "QBox #{access_token}"}
    self.class.post(url, headers: headers)
  end

  def get_download_token(file_key, file_name, deadline=1.hour)
    opts = {
      scope: Settings.qiniu_bucket,
      deadline: Time.now.to_i + deadline,
      key: file_key
    }
    token = self.generate_download_token(opts, file_name)
    "http://#{opts[:scope]}.qiniudn.com/#{opts[:key]}?download/#{URI::encode file_name}&e=#{opts[:deadline]}&token=#{token}"
  end

  def get_upload_token()
    self.generate_upload_token(
      scope: Settings.qiniu_bucket,
      deadline: Time.now.to_i + 1.hour,
      returnBody: '{"file_name": $(fname), "is_public": $(x:is_public), "content_type": $(mimeType), "file_key": $(etag), "url": $(x:url), "lang": $(x:lang), "size": $(fsize)}'
    )
  end

  def range_top(range_type, range, type, limit)
    Parse::Query.new(@klass).tap do |klass_query|
      klass_query.eq('objectId', {
        '$select' => {
          'query' => {
            'className' => 'DownloadRecord',
            'where' => {
              'range' => range,
              'range_type' => range_type,
              'type' => @klass.underscore
            }
          },
          'key' => 'item_id',
          'order_by' => '-count',
          'limit' => limit
        }
      })
    end.get
  end

  private
  def generate_upload_token(opts={})
    signature = urlsafe_base64_encode(opts.to_json)
    encoded_digest = self.generate_encoded_digest(signature)
    %Q(#{Settings.qiniu_appkey}:#{encoded_digest}:#{signature})
  end

  def generate_download_token(opts={}, file_name)
    url = "http://#{opts[:scope]}.qiniudn.com/#{opts[:key]}?download/#{URI::encode file_name}&e=#{opts[:deadline]}"
    encode_sign = self.generate_encoded_digest(url)
    %Q(#{Settings.qiniu_appkey}:#{encode_sign})
  end

  def generate_encoded_entry_uri(file_key)
    urlsafe_base64_encode "#{file_key}:#{Settings.qiniu_bucket}"
  end
end
