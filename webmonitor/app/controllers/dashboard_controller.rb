class DashboardController < ApplicationController

  def index
    respond_to do |format|
      format.html
    end
  end

  def get_temperature
    temperature_and_time = Watcher.get_temperature
    current_temperature = temperature_and_time[1]
    datetime = temperature_and_time[0]

    Temperature.create(:sensor_id => 1, :value => current_temperature, :checking => datetime)

    respond_to do |format|
      format.html { redirect_to dashboard_path }
    end
  end

  def current_temperature
    current_temperature = Watcher.get_temperature[1]

    respond_to do |format|
      format.html { render :inline => current_temperature }
    end
  end

end
