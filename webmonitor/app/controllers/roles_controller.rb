class RolesController < ApplicationController
  def index
    @users = User.all
    respond_to do |format|
      format.html
    end
  end

  def new
    @user = User.new
    respond_to do |format|
      format.html
    end
  end

  def edit
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
end
