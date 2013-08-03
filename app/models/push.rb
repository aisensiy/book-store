class Push < BaseClient
   def self.push_to_device(data)
     post('/1/push', body: JSON.dump(data))
   end

   def self.send_url_to_user_device(user, type, item_id)
     download_file_id = UploadFile.create_download_file(item_id, type, user['objectId'])['objectId']
     data = {'where' => {'owner' => {'$inQuery' => {'email' => user['email']}}}, 'data' => {'alert' => download_file_id}}
     self.push_to_device(data)
   end

end
