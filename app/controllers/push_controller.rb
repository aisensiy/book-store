class PushController < ApplicationController
  def push
    resp = Push.push_to_device(params[:data])
    render status: resp.code, json: resp.body
  end
end
