require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = {
      username: 'thisisatest',
      password: '000000a',
      email: 'aisensiy@gmail.com'
    }
    @users_id = []
  end

  test "should create a new user and then signout" do
    post :create, user: @user
    result = JSON.parse(@response.body)
    assert_equal result['objectId'], session[:user_id]
    assert_equal result['sessionToken'], session[:token]
    @users_id << [session[:user_id], session[:token]]
    delete :signout
    assert_nil session[:user_id]
    assert_nil session[:token]
  end

  test "should signin successfully" do
    User.signup(@user)
    post :signin, user: @user
    result = JSON.parse(@response.body)
    assert_equal result['objectId'], session[:user_id]
    assert_equal result['sessionToken'], session[:token]
    @users_id << [session[:user_id], session[:token]]
  end

  teardown do
    @users_id.each do |user|
      User.remove(user[0], user[1])
    end
  end
end
