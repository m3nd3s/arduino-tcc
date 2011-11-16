class SystemConfigurationsController < ApplicationController

  def edit
    @configuration = SystemConfiguration.first
    @configuration ||= SystemConfiguration.new()

     respond_to do |format|
       format.html
     end
  end

  def show
    @configuration = SystemConfiguration.first

    respond_to do |format|
      format.html
    end
  end

  def update
    @configuration = SystemConfiguration.first
    respond_to do |format|
      if @configuration.update_attributes( params[:system_configuration] )
        format.html { redirect_to edit_system_configurations_path }
      else
        format.html { render :edit }
      end
    end
  end

  def create
    @configuration = SystemConfiguration.new(params[:system_configuration])
    respond_to do |format|
      if @configuration.save
        format.html { redirect_to system_configurations_path }
      else
        format.html { render :edit }
      end
    end
  end

end
