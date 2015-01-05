class StreaksController < ApplicationController
  before_filter :authorize

  def streaks
  end

  def index
    requested_date = Time.at(params[:date].to_i/1000).to_date()

    respond_to do |format|
      format.json { render :json => UserItem.where("user_id = ? AND date = ?", @user.id, requested_date) }
    end
  end
end
