class DashboardController < ApplicationController

  def index
    @temperatures = Temperature.where("sensor_id = ? AND checking BETWEEN ? AND ?", 0, Time.now - 1.day, Time.now)
    @temperatures_to_chart = @temperatures.collect { |t| t.value }

    @temperatures_to_chart = [0] unless @temperatures_to_chart

    respond_to do |format|
      format.html
    end
  end

end
