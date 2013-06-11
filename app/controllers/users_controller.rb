class UsersController < ApplicationController
  def create
    resp = User.signup(params[:user])
    if resp.code == 201
      set_session(resp)
    end
    render status: resp.code, json: resp.body
  end

  def signin
    resp = User.signin(params[:user])

    if resp.code == 200
      set_session(resp)
    end

    render status: resp.code, json: resp.body
  end

  def signout
    reset_session
    render json: {}
  end

  private
  def set_session(resp)
    session[:token] = resp.parsed_response['sessionToken']
    session[:user_id] = resp.parsed_response['objectId']
  end
end
