class UsersController < ApplicationController
  before_filter :authorize, :except => [:login, :register, :welcome, :key]
  before_filter :redirect,  :except => [:logout]

  def welcome
  end
  
  def register
    user = User.register(params[:username], params[:password], params[:name])

    respond_to do |format|
      if user.valid?
        session[:user_id] = user.id
        session[:preferences] = user.preferences
        format.json { render json: {}, status: :accepted}
      else
        if (true == user.errors.has_key?(:password))
          user.errors.delete(:hashed_password)
        elsif (true == user.errors.has_key?(:hashed_password))
          user.errors.delete(:hashed_password)
          user.errors[:server] = ["has error storing password"]
        end

        format.json { render json: user.errors, status: :unauthorized }
      end
    end
  end
  
  def login
    user = User.authenticate(params[:username], params[:password])

    respond_to do |format|
      if user
        session[:user_id] = user.id
        session[:preferences] = user.preferences
        format.json { render json: {}, status: :accepted }
      else
        format.json { render json: {}, status: :unauthorized }
      end
    end
  end

  def logout
    reset_session
    redirect_to(:action => "welcome")
  end

  def key
    respond_to do |format|
      format.json { render json: User.public_key }
    end
  end
end
