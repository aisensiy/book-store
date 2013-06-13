require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = {
      username: 'atest' + Time.new.to_i.to_s[5..-1],
      password: '000000a',
      email: "yisn#{Time.new.to_i.to_s[5..-1]}@gmail.com"
    }
    @users_id = []
  end

  test "should create a new user and then signout" do
    post :create, user: @user
    @users_id << [session[:user_id], session[:token]]
    result = JSON.parse(@response.body)
    assert_equal result['objectId'], session[:user_id]
    assert_equal result['sessionToken'], session[:token]
    delete :signout
    assert_nil session[:user_id]
    assert_nil session[:token]
  end

  test "should signin successfully" do
    User.signup(@user)
    post :signin, user: @user
    @users_id << [session[:user_id], session[:token]]
    result = JSON.parse(@response.body)
    assert_equal result['objectId'], session[:user_id]
    assert_equal result['sessionToken'], session[:token]
  end

  test "current_user" do
    User.signup(@user)
    post :signin, user: @user
    @users_id << [session[:user_id], session[:token]]

    get :current_user
    assert_equal(@user[:username],
                 JSON.parse(@response.body)["username"])

    delete :signout

    get :current_user
    assert_equal "{\"error\":\"not signin\"}", @response.body
  end

  test "should update user password" do
    User.signup(@user)
    post :signin, user: @user

    put :update, user: {password: '123456'}
    assert_response 200

    delete :signout

    post :signin, user: @user
    assert_response 404

    post :signin, user: {username: @user[:username], password: '123456'}
    assert_response :success
    @users_id << [session[:user_id], session[:token]]
  end

  teardown do
    @users_id.each do |user|
      User.remove(user[0], user[1])
    end
  end
end
