class Push < BaseClient
   def push_to_device(devise_id)
     query = {where: {'objectId': devise_id}}
   end
end
