class ApplicationController < ActionController::Base
  protect_from_forgery

  private
  def authorize
    if (false == session[:user].is_a?(User))
      session[:return_url] = request.url
      redirect_to('/welcome')
    end

    @user = session[:user]
  end

  def redirect
    if (true == session[:user].is_a?(User))
      if (nil != session[:return_url])
        return_url = session[:return_url]
        session.delete(:return_url)
        redirect_to(return_url)
      else
        redirect_to('/calendar')
      end
    end
  end
end
