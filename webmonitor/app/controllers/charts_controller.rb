class ChartsController < ApplicationController

  def show
    sensor_id = params[:sensor_id] || 1
    @temperatures = Temperature.last(15) #where("sensor_id = ? AND checked_at BETWEEN ? AND ?", sensor_id, Time.now - 12.hours, Time.now)
    @temperatures_to_chart = @temperatures.collect { |t| t.value }

    @temperatures_to_chart = [0] unless @temperatures_to_chart


    respond_to do |format|
      format.html
    end
  end

end
