require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should create a new user" do
    post :create, user: {username: 'thisisatest', password: '000000a', email: 'aisensiy@gmail.com'}
    result = JSON.parse(@response.body)
    assert_equal result['objectId'], session[:user_id]
    assert_equal result['sessionToken'], session[:token]
  end
end
