class UsersController < ApplicationController
  def create
    resp = User.signup(params[:user])
    if resp.code == 201
      session[:token] = resp.parsed_response['sessionToken']
      session[:user_id] = resp.parsed_response['objectId']
    end
    render status: resp.code, json: resp.body
  end

  def signin

  end

  def signout

  end

end
