class Push < BaseClient
   def self.push_to_device(data)
     post('/1/push', body: JSON.dump(data))
   end

   def self.send_url_to_user_device(email, type, item_id)
     obj = Parse.get type.classify, item_id
     url = type.classify.constantize.get_download_token obj['file_key'], obj['file_name']
     download_file_id = self.create_download_file type, url
     data = {'where' => {'owner' => {'$inQuery' => {'email' => email}}}, 'data' => {'alert' => download_file_id}}
     self.push_to_device(data)
   end

   private
   def self.create_download_file(type, url)
     download_file = Parse::Object.new('DownloadFile')
     download_file['type'] = type
     download_file['url'] = url
     result = download_file.save
     result['objectId']
   end
end
