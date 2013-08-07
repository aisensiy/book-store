class UsersController < ApplicationController
  before_filter :signin?, only: [:update, :current_user, :signout]
  before_filter :captcha_validate, only: [:signin, :create, :password_reset]

  def create
    begin
      user = Parse::User.new(user_params)
      user.save
    rescue Exception => e
      render status: 403, json: e
    else
      render json: user
    end
  end

  def signin
    resp = User.signin(params[:user])

    if resp.code == 200
      # Parse::User.authenticate params[:user][:username], params[:user][:password]
      set_session(resp)
      Parse.client.session_token = session[:token]
      role = User.get_role(session[:user_id])
      session[:user_role] = if role.nil? then 'Members' else role end
      session[:username] = params[:user][:username]
    end

    render status: resp.code, json: resp.body
  end

  def signout
    reset_session
    render json: {}
  end

  def current_user
    render json: {username: session[:username]}
  end

  def update
    resp = User.update(session[:user_id], session[:token], params[:user])
    render status: resp.code, json: resp.body
  end

  def password_reset
    resp = User.password_reset(params[:email])
    render status: resp.code, json: resp.body
  end

  private
  def set_session(resp)
    session[:token] = resp.parsed_response['sessionToken']
    session[:user_id] = resp.parsed_response['objectId']
  end

  def captcha_validate
    return if Rails.env == 'test'
    if !captcha_valid? params[:captcha]
      render status: 403, json: {error: 'invalid captcha'}
      return false
    end
  end

  def user_params
    params.require(:user).permit(:username, :password, :email)
  end
end
