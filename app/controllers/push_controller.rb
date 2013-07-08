class PushController < ApplicationController
  def push
    resp = Push.push_to_device(params)
    render status: resp.code, json: resp.body
  end
end
