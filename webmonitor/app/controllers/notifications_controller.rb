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

  def edit
    @notification = Notification.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

end
