class UsersController < ApplicationController
  before_filter :signin?, only: [:update, :current_user, :signout]
  before_filter :captcha_validate, only: [:signin, :create]

  def create
    resp = User.signup(params[:user])
    if resp.code == 201
      set_session(resp)
      session[:username] = params[:user][:username]
    end
    render status: resp.code, json: resp.body
  end

  def signin
    resp = User.signin(params[:user])

    if resp.code == 200
      set_session(resp)
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

  private
  def set_session(resp)
    session[:token] = resp.parsed_response['sessionToken']
    session[:user_id] = resp.parsed_response['objectId']
  end

  def signin?
    if not session[:username]
      render status: 403, json: {error: 'not signin'}
      return false
    end
  end

  def captcha_validate
    return if Rails.env == 'test'
    if !captcha_valid? params[:captcha]
      render status: 403, json: {error: 'invalid captcha'}
      return false
    end
  end
end
