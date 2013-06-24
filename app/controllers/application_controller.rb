class ApplicationController < ActionController::Base
  # reset captcha code after each request for security
  after_filter :reset_last_captcha_code!

  protected
  def signin?
    if not session[:username]
      render status: 403, json: {error: 'not signin'}
      return false
    end
  end
end
