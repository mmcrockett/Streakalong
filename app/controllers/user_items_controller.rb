class UserItemsController < ApplicationController
  before_filter :authorize

  def calendar
  end

  def streaks
  end

  def show
    respond_to do |format|
      #format.json { render :json => UserItem.where("user_id = ? AND date = ?", session[:user_id], params[:id]).order(:item_id) }
      format.json { render :json => @user_id }
    end
  end

  def create
    @user_item = UserItem.new()
    @user_item.user_id = @user_id
    @user_item.date    = params[:date]
    @user_item.item_id = params[:item_id]

    respond_to do |format|
      if @user_item.save
        format.json { render :json => @user_item, :status => :created, :location => @user_item}
      else
        format.json { render :json => @user_item.errors, :status => :unprocessable_entity }
      end
    end
  end
end
