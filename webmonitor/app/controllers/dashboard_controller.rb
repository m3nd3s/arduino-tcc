class DashboardController < ApplicationController

  def index
    sensor_id = params[:sensor_id] || 1
    @temperatures = Temperature.where("sensor_id = ? AND checking BETWEEN ? AND ?", sensor_id, Time.now.beginning_of_day, Time.now.end_of_day)
    @temperatures_to_chart = @temperatures.collect { |t| t.value }

    @temperatures_to_chart = [0] unless @temperatures_to_chart

    respond_to do |format|
      format.html
    end
  end

end
