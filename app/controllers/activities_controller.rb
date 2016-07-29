class ActivitiesController < ApplicationController
  before_filter :streakalong_load_user
  before_filter :streakalong_authorize

  # GET /activities
  # GET /activities.json
  def index
    requested_date = Time.at(params[:date].to_i/1000).utc.to_date()

    @activities = @user.activities.where("date = ?", requested_date)
  end

  # POST /activities
  # POST /activities.json
  def create
    save_status = false

    if (nil == params[:id])
      @activity = Activity.new(params.require(:activity).permit(:amount, :item_id, :date))
      @activity.user = @user
      save_status = @activity.save
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