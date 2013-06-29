class Push < BaseClient
   def self.push_to_device(data)
     post('/1/push', body: data)
   end
end
