class Push < BaseClient
   def self.push_to_device(data)
     post('/1/push', body: JSON.dump(data))
   end

   def self.send_url_to_user_device(email, type, item_id)
     data = {'where' => {'owner' => {'$inQuery' => {'email' => email}}}, 'data' => {'alert' => "#{type} #{item_id}"}}
     self.push_to_device(data)
   end
end
