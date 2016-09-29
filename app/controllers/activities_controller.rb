class ActivitiesController < ApplicationController
  before_filter :streakalong_load_user
  before_filter :streakalong_authorize

  # GET /activities
  # GET /activities.json
  def index
    @activities = @user.activities.where("date = ?", requested_date(params[:date]))
  end

  def calories
    @activity = @user.activities.where("date = ?", requested_date(params[:date])).first

    if (nil == @activity)
      @activity = @user.activities.new
      @activity.date = requested_date(params[:date])
    end
  end

  # POST /activities
  # POST /activities.json
  def create
    save_status = false

    if (nil == params[:id])
      ruby_date = Activity.new(params.require(:activity).permit(:date)).date
      @activity = @user.activities.find_by(params.require(:activity).permit(:item_id).merge({:date => ruby_date}))

      if (nil != @activity)
        save_status = @activity.update(params.require(:activity).permit(:amount))
      else
        @activity = Activity.new(params.require(:activity).permit(:amount, :item_id, :date))
        @activity.user = @user
        save_status = @activity.save
      end
    else
      @activity = @user.activities.find_by({:id => params[:id]})
      save_status = @activity.update(params.require(:activity).permit(:amount))
    end

    respond_to do |format|
      if (nil == @activity)
        format.json { render json: {}, status: :unauthorized }
      elsif (true == save_status)
        format.json { render :show, status: :created }
      else
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end
end
