class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private
  def requested_time(unix_epoch)
    return Time.at(unix_epoch.to_i/1000).utc
  end

  def requested_date(unix_epoch)
    return requested_time(unix_epoch).to_date()
  end

  def streakalong_load_user
    #debugger
    if (nil == @user)
      if (true == session[:user_id].is_a?(Integer))
        @user = User.find_by({:id => session[:user_id]})

        if (nil == @user)
          Rails.logger.warn("Couldn't find user with session[:user_id] '#{session[:user_id]}'! Logging out.")

          respond_to do |format|
            format.html { redirect_to('/logout') }
            format.json { render json: {}, status: :unauthorized }
          end
        end
      end
    end
  end

  def streakalong_authorize
    if (false == @user.is_a?(User))
      respond_to do |format|
        format.html { session[:return_url] = request.url; redirect_to('/welcome') }
        format.json { render json: {}, status: :unauthorized }
      end
    end
  end

  def streakalong_redirect
    if (true == @user.is_a?(User))
      if (false == @user.complete_or_ignore?)
        return_url = '/settings'
      elsif (nil != session[:return_url])
        return_url = session[:return_url]
      else
        return_url = '/activities'
      end

      session.delete(:return_url)

      respond_to do |format|
        format.html { redirect_to(return_url) }
        format.json { render json: {}, status: :unprocessable_entity }
      end
    end
  end
end
