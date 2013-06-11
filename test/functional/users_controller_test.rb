require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @users_id = []
  end

  test "should create a new user" do
    post :create, user: {username: 'thisisatest', password: '000000a', email: 'aisensiy@gmail.com'}
    result = JSON.parse(@response.body)
    assert_equal result['objectId'], session[:user_id]
    assert_equal result['sessionToken'], session[:token]
    @users_id << session[:user_id]
  end

  teardown do
    @users_id.each do |user_id|
      User.remove(user_id, session[:token])
    end
  end
end
