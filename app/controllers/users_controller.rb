class UsersController < ApplicationController
  before_filter :streakalong_load_user, :except => [:logout]
  before_filter :streakalong_authorize, :except => [:login, :create, :welcome, :logout]
  before_filter :streakalong_redirect,  :except => [:logout, :update, :settings]

  def create
    user = User.register(params[:username], params[:password], params[:name])

    respond_to do |format|
      if user.valid?
        session[:user_id] = user.id
        format.json { render json: {}, status: :accepted}
      else
        format.json { render json: user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if (true == @user.update(user_params))
        format.json { render :settings }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def login
    user = User.authenticate(params[:username], params[:password])

    respond_to do |format|
      if user
        session[:user_id] = user.id
        format.json { render json: {}, status: :accepted }
      else
        format.json { render json: {}, status: :unauthorized }
      end
    end
  end

  def logout
    reset_session
    @user = nil
    redirect_to(:action => "welcome")
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:name, :gender, :height, :birthday)
  end
end
