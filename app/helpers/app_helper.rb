module AppHelper
  def write_authority(object)
    return if !session[:user_id]
    cur_user = session[:user_id]
    role = session[:user_role] || "Members"
    if object['ACL'][cur_user] && object['ACL'][cur_user]['write'] == true ||
       object['ACL']["role:#{role}"] && object['ACL']["role:#{role}"]["write"] == true
      object['write'] = true
    end
    object
  end

  def process_authorities(objects)
    objects.each do |object|
      write_authority(object)
    end
    objects
  end
end
