class Push < BaseClient
   def self.push_to_device(data)
     post('/1/push', body: JSON.dump(data))
   end
end
