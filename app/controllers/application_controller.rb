class ApplicationController < ActionController::Base
  protect_from_forgery

  private
    def authorize
      unless User.find_by_id(session[:user_id])
        session[:return_url] = request.url
        redirect_to('/welcome')
      end

      @user_id = session[:user_id]
    end

    def redirect
      if (session[:user_id])
        if (session[:return_url])
          return_url = session[:return_url]
          session.delete(:return_url)
          redirect_to(return_url)
        else
          redirect_to('/calendar')
        end
      end
    end
end
