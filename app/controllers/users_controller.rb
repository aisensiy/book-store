class UsersController < ApplicationController
  def create
    resp = User.signup(params[:user])
    if resp.code == 201
      set_session(resp)
    end
    render status: resp.code, json: resp.body
  end

  def signin
    logger.debug params["user"]
    resp = User.signin(params["user"])

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
    if session[:username]
      render json: {username: session[:username]}
    else
      render status: 403, json: {error: 'not signin'}
    end
  end

  private
  def set_session(resp)
    session[:token] = resp.parsed_response['sessionToken']
    session[:user_id] = resp.parsed_response['objectId']
  end
end
