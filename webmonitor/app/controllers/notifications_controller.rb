class NotificationsController < ApplicationController 
  def index
    @notifications = Notification.all

    respond_to do |format|
      format.html
    end
  end

  def new
    @notification = Notification.new
    respond_to do |format|
      format.html
    end
  end

  def create
    @notification = Notification.new( params[:notification] )
    respond_to do |format|
      if @notification.save
        format.html { redirect_to notifications_path }
      else
        format.html { render :new }
      end
    end
  end

  def update
    @notification = Notification.find(params[:id])
    respond_to do |format|
      if @notification.update_attributes( params[:notification] )
        format.html { redirect_to notifications_path }
      else
        format.html { render :new }
      end
    end
  end

  def edit
    @notification = Notification.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @notification = Notification.find(params[:id])
    @notification.destroy
    respond_to do |format|
      format.html { redirect_to notifications_path }
    end
  end

end
