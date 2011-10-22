class DashboardController < ApplicationController

  def index
    sensor_id = params[:sensor_id] || 1
    @temperatures = Temperature.where("sensor_id = ? AND checking BETWEEN ? AND ?", sensor_id, Time.now - 12.hours, Time.now)
    @temperatures_to_chart = @temperatures.collect { |t| t.value }

    @temperatures_to_chart = [0] unless @temperatures_to_chart

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
