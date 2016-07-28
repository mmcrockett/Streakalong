class PreferencesController < ApplicationController
  before_filter :streakalong_load_user
  before_filter :streakalong_authorize

  def index
  end

  def create
    @user.preferences = preference_params
    respond_to do |format|
      if @user.save
        format.json { render :index, status: :created }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def preference_params
    return params.require(:preference)
  end
end
