class UserItemsController < ApplicationController
  before_filter :authorize

  def calendar
  end

  def streaks
  end

  def index
    requested_date = Time.at(params[:date].to_i/1000).utc.to_date()

    respond_to do |format|
      format.json { render :json => UserItem.where("user_id = ? AND date = ?", @user.id, requested_date) }
    end
  end

  def create
    @user_item = UserItem.new(params[:user_item])
    @user_item.user_id = @user.id

    respond_to do |format|
      if @user_item.save
        @user.add_preference(UserPreference::RECENT, @user_item.item_id)
        format.json { render :json => @user_item, :status => :created, :location => @user_item}
      else
        format.json { render :json => @user_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    params[:user_item].delete(:user_id)
    @user_item = UserItem.where("id = ? AND user_id = ?", params[:id], @user.id).first

    respond_to do |format|
      if (nil == @user_item)
        format.json { render :json => {}, :status => :unprocessable_entity }
      elsif (@user_item.update_attributes(params[:user_item]))
        @user.add_preference(UserPreference::RECENT, @user_item.item_id)
        format.json { render :json => @user_item }
      else
        format.json { render :json  => user_item.errors, :status => :unprocessable_entity }
      end
    end
  end
end
